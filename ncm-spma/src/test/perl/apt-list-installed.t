# -*- mode: cperl -*-
# ${license-info}
# ${author-info}
# ${build-info}

=pod

=head1 DESCRIPTION

More tests for the C<installed_pkgs> method. This time we test that
all the debs are printed in a format that APT will understand.

=head1 TESTS

These tests will run only if the dpkg binary is present.  They consist
on retrieving the set of all installed packages and ensure there are
no surprising strings among them.

=cut

use strict;
use warnings;
use Test::Quattor;
use Test::More;
use NCM::Component::spma::apt;

plan skip_all => "Cannot test get_installed_pkgs, dpkg not present" if ! -x "/usr/bin/dpkg";

my $cmp = NCM::Component::spma::apt->new("spma");

my $pkgs = $cmp->get_installed_pkgs();
isa_ok($pkgs, "Set::Scalar", "installed_pkgs()");

foreach my $pkg (@$pkgs) {
    print $pkg;
    like($pkg, qr{^(?:[-+\.\w]+)(?:;\w+)?$}, "Package $pkg has the correct format string");
    like($pkg, qr{^([\w\.\-\+]+)[*?]?}, "Package $pkg matches our wildcard regexp");
}

done_testing();
