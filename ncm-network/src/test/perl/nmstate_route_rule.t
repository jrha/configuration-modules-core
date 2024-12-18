use strict;
use warnings;

BEGIN {
    *CORE::GLOBAL::sleep = sub {};
}

use Test::More;
use Test::Quattor qw(nmstate_route_rule);
use Test::MockModule;
use Readonly;

use NCM::Component::nmstate;
my $mock = Test::MockModule->new('NCM::Component::nmstate');
my %executables;
$mock->mock('_is_executable', sub {diag "executables $_[1] ",explain \%executables;return $executables{$_[1]};});

my $cfg = get_config_for_profile('nmstate_route_rule');
my $cmp = NCM::Component::nmstate->new('network');

Readonly my $RULE_YML => <<EOF;
# File generated by NCM::Component::nmstate. Do not edit
---
interfaces:
- ipv4:
    address:
    - ip: 4.3.2.1
      prefix-length: 24
    dhcp: false
    enabled: true
  mac-address: 6e:a5:1b:55:77:0a
  name: eth0
  profile-name: eth0
  state: up
  type: ethernet
route-rules:
  config:
  - action: unreachable
    family: ipv4
    fwmark: '111'
    fwmask: '000'
    iif: eth0
    ip-to: 1.2.3.4/24
    priority: 100
  - action: prohibit
    family: ipv4
    ip-to: 1.2.4.4/24
    priority: 100
    state: absent
routes:
  config:
  - next-hop-interface: eth0
    state: absent
  - destination: 0.0.0.0/0
    next-hop-address: 4.3.2.254
    next-hop-interface: eth0
EOF

is($cmp->Configure($cfg), 1, "Component runs correctly with a test profile");

my $ruleyml = get_file_contents("/etc/nmstate/eth0.yml");
is($ruleyml, $RULE_YML, "Exact eth0 rule yml config");

done_testing();
