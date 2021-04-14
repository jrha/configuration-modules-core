# ${license-info}
# ${developer-info}
# ${author-info}

=head1 NAME

NCM::hostsfile - NCM local hosts file configuration component.

=head1 SYNOPSIS

configure local /etc/hosts settings and resources as per CDB

=over 4

=item Configure()

Updates the C<< /etc/hosts >> file with the entries specified within the
configuration. The entries in the configuration are keyed by the primary
hostname. If an entry describes a hostname which is already in C<< /etc/hosts >>
(either as a primary hostname, or as an alias), then that host entry will
be left alone (if takeover is false), or will be completely replaced by
the entry specified in the configuration (if takeover is true).

A comment C<< # NCM >> is added to each line so that any deletions will also be
cleaned up correctly.

Returns error in case of a failure.

=back

=cut

package NCM::Component::hostsfile;

use strict;
use base 'NCM::Component';

our $EC = LC::Exception::Context->new->will_store_all;
our $NoActionSupported = 1;

use LC::Check;
use LC::File;

sub Configure {
    my ( $self, $config ) = @_;

    my $valPath = '/software/components/hostsfile';

    unless ( $config->elementExists($valPath) ) {
        $self->error("cannot get $valPath");
        return;
    }

    my $allow_takeover = 0;
    my $re;             # root element (of subtrees in our config)
    my $val;            # value (temporary) retrieved for a given config element
    my $reload    = 0;  # shall we reload the config file?
    my $errorflag = 0;  # fatal error

    if ($config->elementExists("$valPath/takeover")) {
        $allow_takeover = $config->getElement("$valPath/takeover")->getValue();
    }

    # Structure is
    #   hostsfile
    #	file
    #	entries
    #	    <hostname>
    #		ipaddr
    #	    	aliases = list
    #
    my $hostsfile = "/etc/hosts";
    my $cdbpath   = $valPath . "/file";
    my @fields;
    my $all_aliases = {};
    my %non_ncm_hosts;
    my %ncmhosts;
    my %newncmhosts;
    if ( $config->elementExists($cdbpath) ) {
        $re        = $config->getElement("$cdbpath");
        $hostsfile = $re->getValue();
    }

    my @order = (); # how to maintain the same ordering of hosts

    # Parse the existing file, categorising each entry as NCM-controlled or not.
    # We keep track of the order of lines to put things back in the same
    # order, including comments. We also track the aliases, so that if
    # someone tries to define "foo" within the configuration, and in the
    # pre-existing /etc/hosts file it has IP HOST.DOMAIN FOO (i.e. FOO is
    # supposed to be an alias for HOST.DOMAIN), then we will throw away the
    # HOST.DOMAIN line and replace it with this new definition. This is
    # "do what I mean", but might potentially cause confusion if your config
    # is very broken.
    my $lines = LC::File::file_contents($hostsfile);
    foreach my $line (split(/\n+/, $lines)) {
        # We completely skip the prologue, since we'll generate a new one
        next if ($line =~ /^\# Generated by Quattor/);

        if ($line =~ /^#/) {
            push(@order, $line);
            next;
        }

        my $stash;
        if ($line =~ /\# NCM/) {
            $stash = \%ncmhosts;
        } else {
            $stash = \%non_ncm_hosts;
        }
        my ($nocomment) = ($line =~ m{^([^#]*)});
        @fields = split( /\s+/, $nocomment);
        my $host = $fields[1];
        foreach my $h (@fields[2..$#fields]) {
            $all_aliases->{$h} = $host;
        }
        $stash->{$host} = $line;
        push(@order, $host);
    }

    # Now build the lines for the hosts file
    $cdbpath = $valPath . "/entries";
    if ( $config->elementExists($cdbpath) ) {
        $re = $config->getElement("$cdbpath");
        while ( $re->hasNextElement() ) {
            my $he     = $re->getNextElement();
            my $heval  = $he->getValue();
            my $hename = $he->getName();                            # Hostname
            my $helist = $config->getElement("$cdbpath/$hename");
            my %hesettings;
            my $line = "";
            my $ipaddr;
            my $comment;
            my $aliases;

            while ( $helist->hasNextElement() ) {
                my $hl     = $helist->getNextElement();
                my $hlval  = $hl->getValue();
                my $hlname = $hl->getName();
                if ( $hlname eq "ipaddr" ) {
                    $ipaddr = $hlval;
                } elsif ( $hlname eq "aliases" ) {
                    $aliases = $hlval;
                } elsif ( $hlname eq "comment" ) {
                    $comment = $hlval;
                } else {
                    $self->error(
                        "List entry $hlname for $hename not understood");
                    $errorflag = 1;
                }
            }
            unless ( defined($ipaddr) ) {
                $self->error("IP address not defined for $hename");
                $errorflag = 1;
            }
            $line = "$ipaddr\t$hename";
            if ( !defined($aliases) ) {
                $aliases = $hename;
            }
            $line .= " $aliases";
            $line = sprintf( "%-40s # NCM", $line );
            if ( defined($comment) ) {
                $line .= " $comment";
            }
            my $aka = $hename;
            if (exists $all_aliases->{$hename}) {
                $aka = $all_aliases->{$hename};
            }

            if (exists $ncmhosts{$aka} || exists $non_ncm_hosts{$aka}) {
                my $stash;
                if (exists $ncmhosts{$aka}) {
                    if ($ncmhosts{$aka} ne $line) {
                        $self->info("changing entry for NCM-controlled $hename");
                    }
                    $stash = \%ncmhosts;
                } elsif ($allow_takeover) {
                    if ($non_ncm_hosts{$aka} ne $line) {
                        $self->info("taking over entry for $hename");
                    }
                    $stash = \%non_ncm_hosts;
                } else {
                    $self->info("will not takeover entry for $hename");
                    next;
                }

                delete $stash->{$aka};
            } else {
                $self->info("new entry for $aka");
            }


            if ( exists( $newncmhosts{$aka} ) ) {
                $self->error("Duplicate entry for $aka");
                $errorflag = 1;
            }
            $newncmhosts{$aka} = $line;
            $reload = 1;
        }
    }

    my @oldhosts = keys %ncmhosts;
    if ( @oldhosts > 0 ) {
        $reload = 1;
        my $ohosts = join( ' ', @oldhosts );
        $self->info("Deleting entries for $ohosts");
        $reload = 1;
    }
    if ( $reload && !$errorflag ) {
        my $contents = "";
        $contents .= '# Generated by Quattor component hostsfile 2.0.0';
        $contents .= "\n";

        # Run through all the modified hosts (i.e. maintaining previous order)
        foreach my $h (@order) {
            if ($h =~ m{^#}) {
                $contents .= "$h\n";
                next;
            }
            my $le;
            if (exists $newncmhosts{$h}) {
                $le = delete $newncmhosts{$h};
            } elsif (exists $ncmhosts{$h}) {
                next;
            } else {
                $le = delete $non_ncm_hosts{$h};
            }
            $contents .= "$le\n"
        }

        # After that loop above, we should be left with only new hosts
        foreach my $h (sort keys %newncmhosts) {
            $contents .= $newncmhosts{$h} . "\n";
        }

        my $update = LC::Check::file($hostsfile,
                                     contents => $contents,
                                     owner => 'root',
                                     mode => oct(644));
        if (!defined $update) {
            $self->error("Cannot update $hostsfile : $!");
            return;
        }
    }
    if ( $errorflag ) {
        return;
    }
    return 1;
}

sub Unconfigure {
    # Not implemented
}

1;    #required for Perl modules
