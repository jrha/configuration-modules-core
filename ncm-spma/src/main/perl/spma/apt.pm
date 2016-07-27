# ${license-info}
# ${developer-info}
# ${author-info}

package NCM::Component::spma::apt;

=head1 NAME

NCM::Component::spma::apt - NCM SPMA backend for apt

=head1 SYNOPSIS

This document describes how to control the behaviour of the package manager itself.
For information on how to manage packages with Quattor, please check
L<http://quattor.org/documentation/2013/04/05/package-management.html>.

=head1 DESCRIPTION

apt.pm implements an apt backend for ncm-spma, the approach taken is to defer as much work as possible to apt.

A single SPMA run consists of the following steps:

=over

=item

Setup repository directory if required

=item

Remove repositories that are not found in the profile

=item

Update repository cache from upstream sources

=item

Upgrade already installed packages

=item

Install packages specified in the profile that are not installed

=item

Mark any packages installed but not in the profile as automatically installed

=item

Ask apt to remove all automatically installed packages that are not satisfying dependencies of other packages

=back

Support for groups (tasks) is not currently provided.

=head1 RESOURCES

Only a very minimal schema is implemented.

Repositories listed under C</software/repositories> will be configured,
URLs should be followed by the suite and sections required e.g. http://example.org/debian unstable main

Packages listed under C</software/packages> will be installed, version and architecture locking (including multiarch) is fully implemented.

=cut

use strict;
use warnings;
use NCM::Component;
our $EC=LC::Exception::Context->new->will_store_all;
our @ISA = qw(NCM::Component);
use EDG::WP4::CCM::Element qw(escape unescape);

use CAF::Process;
use CAF::FileWriter;
use CAF::FileEditor;
use LC::Exception qw(SUCCESS);
use Set::Scalar;
use File::Path qw(mkpath);
use Text::Glob qw(match_glob);
use Readonly;

Readonly::Scalar my $DIR_REPOS => "/etc/apt/sources.list.d";
Readonly::Scalar my $DIR_PREFERENCES => "/etc/apt/preferences.d";
Readonly::Scalar my $TEMPLATE_REPOS => "spma/apt-source.tt";
Readonly::Scalar my $TEMPLATE_PREFERENCES => "spma/apt-preferences.tt";
Readonly::Scalar my $TREE_REPOS => "/software/repositories";
Readonly::Scalar my $TREE_PKGS => "/software/packages";
Readonly::Scalar my $TREE_COMPONENT => "/software/components/${project.artifactId}";
Readonly::Scalar my $BIN_APT_GET => "/usr/bin/apt-get";
Readonly::Scalar my $BIN_APT_MARK => "/usr/bin/apt-mark";
Readonly::Scalar my $BIN_DPKG_QUERY => "/usr/bin/dpkg-query";
Readonly::Scalar my $CMD_APT_UPDATE => [$BIN_APT_GET, qw(-qq update)];
Readonly::Scalar my $CMD_APT_UPGRADE => [$BIN_APT_GET, qw(-qq dist-upgrade)];
Readonly::Scalar my $CMD_APT_INSTALL => [$BIN_APT_GET, qw(-qq install)];
Readonly::Scalar my $CMD_APT_AUTOREMOVE => [$BIN_APT_GET, qw(-qq autoremove)];
Readonly::Scalar my $CMD_APT_MARK => [$BIN_APT_MARK, qw(-qq)];
Readonly::Scalar my $CMD_DPKG_QUERY => [$BIN_DPKG_QUERY, qw(-W -f=${db:Status-Abbrev};${Package}\n)];

our $NoActionSupported = 1;


# If user packages are not allowed, removes any repositories present
# in the system that are not listed in $allowed_repos.
sub cleanup_old_repos
{
    my ($self, $repo_dir, $allowed_repos, $allow_user_pkgs) = @_;
    $self->debug(5, 'Entered cleanup_old_repos()');

    return 1 if $allow_user_pkgs;

    my $dir;
    if (!opendir($dir, $repo_dir)) {
        $self->error("Unable to read repositories in $repo_dir");
        return 0;
    }

    my $current = Set::Scalar->new(map(m{(.*)\.list$}, readdir($dir)));

    closedir($dir);
    my $allowed = Set::Scalar->new(map($_->{name}, @$allowed_repos));
    my $rm = $current-$allowed;
    foreach my $i (@$rm) {
        # We use $f here to make Devel::Cover happy
        my $f = "$repo_dir/$i.list";
        $self->verbose("Unlinking outdated repository $f");
        if (!unlink($f)) {
            $self->error("Unable to remove outdated repository $i: $!");
            return 0;
        }
    }
    return 1;
}


# Creates the repository dir if needed.
sub initialize_repos_dir
{
    my ($self, $repo_dir) = @_;
    $self->debug(5, 'Entered initialize_repos_dir()');

    if (! -d $repo_dir) {
        $self->verbose("$repo_dir didn't exist. Creating it");
        if (!eval{mkpath($repo_dir)} || $@) {
            $self->error("Unable to create repository dir $repo_dir: $@");
            return 0;
        }
    }
    return 1;
}


# Returns the URLs of the repositories listed in $prots, with their
# host part replaced by each of the reverse @proxies.
sub generate_reverse_proxy_urls
{
    my ($self, $prots, @proxies) = @_;
    $self->debug(5, 'Entered generate_reverse_proxy_urls()');

    my @l;
    foreach my $pt (@$prots) {
        foreach my $px (@proxies) {
            my $url = $pt->{url};
            $url =~ s{^(.*?):(/+)[^/]+}{$1:$2$px};
            push(@l, { url => $url });
        }
    }
    return \@l;
}


# Generate the URLs for the forward proxies, based on whether the
# repository is accessible over HTTP or HTTPS.
sub generate_forward_proxy_urls
{
    my ($self, $proto, @px) = @_;
    $self->debug(5, 'Entered generate_forward_proxy_urls()');

    $proto->[0]->{url} =~ m{^(.*?):};
    return "$1://$px[0]";
}


# Generates the repository files in $repos_dir based on the contents
# of the $repos subtree. It uses Template::Toolkit $template to render
# the file. Optionally, proxy information will be used. In that case,
# it will use the $proxy host, wich is of $type "reverse" or
# "forward", and runs on the given $port.
# Returns undef on errors, or the number of repository files that were changed.
sub generate_repos
{
    my ($self, $repos_dir, $repos, $template, $proxy, $type, $port) = @_;
    $self->debug(5, 'Entered generate_repos()');

    my @px = split(",", $proxy) if $proxy;
    @px = map("$_:$port", @px) if $port;

    my $changes = 0;

    foreach my $repo (@$repos) {
        my $prots = $repo->{protocols}->[0];
        my $fh = CAF::FileWriter->new("$repos_dir/$repo->{name}.list", log => $self);
        print $fh "# File generated by ", __PACKAGE__, ". Do not edit\n";
        if (!exists($repo->{proxy}) && @px) {
            if ($type eq 'reverse') {
                $repo->{protocols} = $self->generate_reverse_proxy_urls($repo->{protocols}, @px);
            } else {
                $repo->{proxy} = $self->generate_forward_proxy_urls($repo->{protocols}, @px);
            }
        }
        my $rs = $self->template()->process($template, $repo, $fh);
        if (!$rs) {
            $self->error ("Unable to generate repository $repo->{name}: ", $self->template()->error());
            $fh->cancel();
            return 0;
        }
        $changes += $fh->close() || 0; # handle undef
        $fh->close();
    }

    return $changes;
}


# Returns a set of all installed packages
sub get_installed_pkgs
{
    my $self = shift;
    $self->debug(5, 'Entered installed_pkgs()');

    my $cmd = CAF::Process->new($CMD_DPKG_QUERY, keeps_state => 1, log => $self);

    my $out = $cmd->output();
    if ($?) {
        return 0;
    }
    my @pkgs = grep(m{^ii }, split(/\n/, $out));
    for (@pkgs) {s/^...;//g}; # Strip package status characters

    return Set::Scalar->new(@pkgs);
}


sub get_package_version_arch
{
    my ($self, $name, $details) = @_;
    $self->debug(5, 'Entered get_package_version_arch()');

    my @versions;

    if ($details) {
        while (my ($ver, $archs) = each(%$details)) {
            if ($archs->{arch}) {
                while (my $arch = each(%$archs->{arch})) {
                    $self->debug(5, '  Adding package ', $name, ' with version ', $ver, ' and architecture ', $arch, ' to list');
                    push(@versions, sprintf('%s:%s=%s', $name, $arch, unescape($ver)));
                }
            }
            else {
                $self->debug(5, '  Adding package ', $name, ' with version ', $ver, ' but without architecture to list');
                push(@versions, sprintf('%s=%s', $name, unescape($ver)));
            }
        }
    }
    else {
        $self->debug(5, '  Adding package ', $name, ' without version or architecture to list');
        push(@versions, $name);
    }

    return \@versions;
}


sub apply_package_version_arch
{
    my ($self, $packagelist, $packagetree) = @_;

    $self->debug(5, 'Entered apply_package_version_arch()');

    my @packages = @$packagelist;
    my @results;

    while (my $name = shift(@packages)) {
        my $name_escaped = escape($name);
        if (exists($packagetree->{$name_escaped})) {
            my $versions = $self->get_package_version_arch($name, $packagetree->{$name_escaped});
            push(@results, @$versions);
        }
        else {
            $self->error('Could not find package ', $name, ' in tree');
        }
    }

    return \@results;
}


# Return a set of desired packages.
sub get_desired_pkgs
{
    my ($self, $pkgs) = @_;
    $self->debug(5, 'Entered get_desired_pkgs()');

    my $packages = Set::Scalar->new();

    while (my $name_escaped = each(%$pkgs)) {
        my $name = unescape($name_escaped);
        if (!$name) {
            $self->error("Invalid package name: ", unescape($name));
            return 0;
        }
        $packages->insert($name);
    }
    return $packages;
}


# Update package metadata from upstream repositories
sub resynchronize_package_index
{
    my $self = shift;
    $self->debug(5, 'Entered resynchronize_package_index()');

    my $cmd = CAF::Process->new($CMD_APT_UPDATE, keeps_state => 1, log => $self);
    $cmd->execute() or return 0;

    return 1;
}


# Upgrade existing packages
sub upgrade_packages
{
    my ($self) = @_;
    $self->debug(5, 'Entered upgrade_packages()');

    my $cmd = CAF::Process->new($CMD_APT_UPGRADE, keeps_state => 1, log => $self);
    $cmd->execute() or return 0;

    return 1;
}


# Install packages
sub install_packages
{
    my ($self, $packages) = @_;
    $self->debug(5, 'Entered install_packages()');

    my $cmd = CAF::Process->new([@$CMD_APT_INSTALL, @$packages], keeps_state => 1, log => $self);
    $cmd->execute() or return 0;

    return 1;
}


# Mark packages as automatically installed
# this signals to apt that they are no longer required and may be cleaned up by autoremove
sub mark_packages_auto
{
    my ($self, $packages) = @_;
    $self->debug(5, 'Entered mark_packages_auto()');

    my $cmd = CAF::Process->new([@$CMD_APT_MARK, 'auto', @$packages], keeps_state => 1, log => $self);
    $cmd->execute() or return 0;

    return 1;
}


# Remove automatically installed packages
sub autoremove_packages
{
    my ($self, $packages) = @_;
    $self->debug(5, 'Entered autoremove_packages()');

    my $cmd = CAF::Process->new([@$CMD_APT_AUTOREMOVE, @$packages], keeps_state => 1, log => $self);
    $cmd->execute() or return 0;

    return 1;
}


sub Configure
{
    my ($self, $config) = @_;
    $self->debug(5, 'Entered Configure()');

    # Get configuration trees
    my $tree_repos = $config->getElement($TREE_REPOS)->getTree();
    my $tree_pkgs = $config->getElement($TREE_PKGS)->getTree();
    my $tree_component = $config->getElement($TREE_COMPONENT)->getTree();
    # Convert these crappily-defined fields into real Perl booleans.
    $tree_component->{run} = $tree_component->{run} eq 'yes';
    $tree_component->{userpkgs} = defined($tree_component->{userpkgs}) && $tree_component->{userpkgs} eq 'yes';

    $self->initialize_repos_dir($DIR_REPOS);
    $self->cleanup_old_repos($DIR_REPOS, $tree_repos, $tree_component->{userpkgs});
    $self->generate_repos(
        $DIR_REPOS,
        $tree_repos,
        $TEMPLATE_REPOS,
        $tree_component->{proxyhost},
        $tree_component->{proxytype},
        $tree_component->{proxyport},
    );

    $self->resynchronize_package_index();

    $self->upgrade_packages();

    my $packages_installed = $self->get_installed_pkgs();
    my $packages_desired = $self->get_desired_pkgs($tree_pkgs);
    my $packages_unwanted = $packages_installed->difference($packages_desired);

    $self->debug(5, 'Installed packages:', $packages_installed);
    $self->debug(5, 'Desired packages:', $packages_desired);
    $self->debug(5, 'Packages installed but unwanted:', $packages_unwanted);

    my $packages_to_install = $self->apply_package_version_arch($packages_desired, $tree_pkgs);

    $self->debug(5, 'Packages to install ', $packages_to_install);

    $self->install_packages($packages_to_install);
    $self->mark_packages_auto($packages_unwanted);
    $self->autoremove_packages();

    return 1;
}


1; # required for Perl modules
