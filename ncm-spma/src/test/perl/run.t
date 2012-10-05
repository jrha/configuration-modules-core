# -*- mode: cperl -*-
# ${license-info}
# ${author-info}
# ${build-info}

=pod

=head1 DESCRIPTION

Tests for the C<apply_transaction> method.  This method executes the
transaction given as an argument into a Yum shell.

=head1 TESTS

This is fairly straightforward: check that Yum is called, and what the
behaviour is upon success or failure.

=cut

use strict;
use warnings;
use Readonly;
use Test::More;
use Test::Quattor;
use NCM::Component::spma;
use CAF::Object;

$CAF::Object::NoAction = 1;

Readonly my $TX => "a transaction text";
Readonly my $YUM => join(" ", NCM::Component::spma::YUM_CMD);

my $cmp = NCM::Component::spma->new("spma");

set_desired_err($YUM, "");
set_desired_output($YUM, "");

is($cmp->apply_transaction($TX), 1, "Transaction succeeds in normal conditions");

my $cmd = get_command($YUM);
ok($cmd, "Yum shell correctly called");
is($cmd->{method}, "execute", "Yum shell was execute'd");
is($cmd->{object}->{OPTIONS}->{stdin}, $TX,
   "Yum shell was given the correct transaction");

set_desired_err($YUM, "\nError: package");

is($cmp->apply_transaction($TX), 0, "Error in transaction detected");
is($cmp->{ERROR}, 1, "Error is reported");

done_testing();
