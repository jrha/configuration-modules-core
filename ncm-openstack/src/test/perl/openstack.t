# -* mode: cperl -*-
use strict;
use warnings;

use Test::More;
use Test::Quattor qw(openstack);
use Test::Quattor::Object;
use Test::MockModule;

use NCM::Component::openstack;

use helper;
use mock_rest qw(openstack);

use Test::Quattor::TextRender::Base;

my $caf_trd = mock_textrender();
my $obj = Test::Quattor::Object->new();


my $cmp = NCM::Component::openstack->new("openstack", $obj);
my $cfg = get_config_for_profile("openstack");

# Test OpenStack component
set_output('keystone_db_version_missing');
set_output('glance_db_version_missing');
set_output('nova_db_version_missing');
set_output('neutron_db_version_missing');
set_output('rabbitmq_db_version_missing');
set_output('cinder_db_version_missing');
set_output('manila_db_version_missing');
set_output('heat_db_version_missing');
set_output('murano_db_version_missing');
set_output('ceilometer_db_version_missing');
set_output('cloudkitty_db_version_missing');
set_output('magnum_db_version_missing');
set_output('barbican_db_version_missing');

ok($cmp->Configure($cfg), 'Configure returns success');
ok(!exists($cmp->{ERROR}), "No errors found in normal execution");

# Check OpenRC script file
my $fhopenrc = get_file("/root/admin-openrc.sh");
isa_ok($fhopenrc, "CAF::FileWriter", "admin-openrc.sh CAF::FileWriter instance");
like("$fhopenrc", qr{^export\s{1}OS_AUTH_URL\=\'http\://controller.mysite.com:35357/v3\'$}m,
    "admin-openrc.sh has expected content");

# Verify Keystone configuration file
my $fh = get_file("/etc/keystone/keystone.conf");
# Only test one entry, the remainder lines
# are verified by TT unittests
isa_ok($fh, "CAF::FileWriter", "keystone.conf CAF::FileWriter instance");
like("$fh", qr{^\[database\]$}m, "keystone.conf has expected content");

# Verify Glance configuration files
$fh = get_file("/etc/glance/glance-api.conf");
isa_ok($fh, "CAF::FileWriter", "glance-api.conf CAF::FileWriter instance");
like("$fh", qr{^\[database\]$}m, "glance-api.conf has expected content");

# Verify Nova configuration files
$fh = get_file("/etc/nova/nova.conf");
isa_ok($fh, "CAF::FileWriter", "nova.conf CAF::FileWriter instance");
like("$fh", qr{^\[DEFAULT\]$}m, "nova.conf has expected content");

# Verify Neutron configuration files
$fh = get_file("/etc/neutron/neutron.conf");
isa_ok($fh, "CAF::FileWriter", "neutron.conf CAF::FileWriter instance");
like("$fh", qr{^\[DEFAULT\]$}m, "neutron.conf has expected content");

$fh = get_file("/etc/neutron/plugins/ml2/ml2_conf.ini");
isa_ok($fh, "CAF::FileWriter", "ml2_conf.ini CAF::FileWriter instance");
like("$fh", qr{^\[securitygroup\]$}m, "ml2_conf.ini has expected content");

$fh = get_file("/etc/neutron/plugins/ml2/linuxbridge_agent.ini");
isa_ok($fh, "CAF::FileWriter", "inuxbridge_agent.ini CAF::FileWriter instance");
like("$fh", qr{^\[linux_bridge\]$}m, "inuxbridge_agent.ini has expected content");

$fh = get_file("/etc/neutron/l3_agent.ini");
isa_ok($fh, "CAF::FileWriter", "l3_agent.ini CAF::FileWriter instance");
like("$fh", qr{^\[DEFAULT\]$}m, "l3_agent.ini has expected content");

$fh = get_file("/etc/neutron/dhcp_agent.ini");
isa_ok($fh, "CAF::FileWriter", "dhcp_agent.ini CAF::FileWriter instance");
like("$fh", qr{^\[DEFAULT\]$}m, "dhcp_agent.ini has expected content");

$fh = get_file("/etc/neutron/metadata_agent.ini");
isa_ok($fh, "CAF::FileWriter", "metadata_agent.ini CAF::FileWriter instance");
like("$fh", qr{^\[DEFAULT\]$}m, "metadata_agent.ini has expected content");

# Verify Dashboard configuration file
$fh = get_file("/etc/openstack-dashboard/local_settings");
isa_ok($fh, "CAF::FileWriter", "dashboard local_settings CAF::FileWriter instance");
like("$fh", qr{^\#\s{1}-\*-\s{1}coding:\s{1}utf-8\s{1}-\*-$}m, "local_settings has expected content");

# Verify Cinder configuration file
$fh = get_file("/etc/cinder/cinder.conf");
isa_ok($fh, "CAF::FileWriter", "cinder.conf CAF::FileWriter instance");
like("$fh", qr{^\[DEFAULT\]$}m, "cinder.conf has expected content");

# Verify Manila configuration file
$fh = get_file("/etc/manila/manila.conf");
isa_ok($fh, "CAF::FileWriter", "manila.conf CAF::FileWriter instance");
like("$fh", qr{^\[DEFAULT\]$}m, "manila.conf has expected content");

# Verify Heat configuration file
$fh = get_file("/etc/heat/heat.conf");
isa_ok($fh, "CAF::FileWriter", "heat.conf CAF::FileWriter instance");
like("$fh", qr{^\[DEFAULT\]$}m, "heat.conf has expected content");

# Verify Murano configuration file
$fh = get_file("/etc/murano/murano.conf");
isa_ok($fh, "CAF::FileWriter", "murano.conf CAF::FileWriter instance");
like("$fh", qr{^\[DEFAULT\]$}m, "murano.conf has expected content");

# Verify Ceilometer configuration files
$fh = get_file("/etc/ceilometer/ceilometer.conf");
isa_ok($fh, "CAF::FileWriter", "ceilometer.conf CAF::FileWriter instance");
like("$fh", qr{^\[DEFAULT\]$}m, "ceilometer.conf has expected content");

$fh = get_file("/etc/gnocchi/gnocchi.conf");
isa_ok($fh, "CAF::FileWriter", "gnocchi.conf CAF::FileWriter instance");
like("$fh", qr{^\[api\]$}m, "gnocchi.conf has expected content");

# Verify Cloudkitty configuration files
$fh = get_file("/etc/cloudkitty/cloudkitty.conf");
isa_ok($fh, "CAF::FileWriter", "cloudkitty.conf CAF::FileWriter instance");
like("$fh", qr{^\[DEFAULT\]$}m, "cloudkitty.conf has expected content");

# Verify Magnum configuration files
$fh = get_file("/etc/magnum/magnum.conf");
isa_ok($fh, "CAF::FileWriter", "magnum.conf CAF::FileWriter instance");
like("$fh", qr{^\[DEFAULT\]$}m, "magnum.conf has expected content");

# Verify Barbican configuration files
$fh = get_file("/etc/barbican/barbican.conf");
isa_ok($fh, "CAF::FileWriter", "barbican.conf CAF::FileWriter instance");
like("$fh", qr{^\[DEFAULT\]$}m, "barbican.conf has expected content");

diag "all servers history commands ", explain \@Test::Quattor::command_history;

ok(command_history_ok([
        'service httpd restart',
        '/bin/bash -c /usr/sbin/rabbitmqctl list_user_permissions openstack',
        '/bin/bash -c /usr/sbin/rabbitmqctl add_user openstack rabbit_pass',
        '/usr/sbin/rabbitmqctl set_permissions openstack .* .* .*',
        '/bin/bash -c /usr/bin/keystone-manage db_version',
        '/bin/bash -c /usr/bin/keystone-manage db_sync',
        '/usr/bin/keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone',
        '/usr/bin/keystone-manage credential_setup --keystone-user keystone --keystone-group keystone',
        '/usr/bin/keystone-manage bootstrap --bootstrap-password admingoodpass',
        'service httpd restart',
        '/bin/bash -c /usr/bin/glance-manage db_version',
        '/bin/bash -c /usr/bin/glance-manage db_sync',
        'service openstack-glance-registry restart',
        'service openstack-glance-api restart',
        '/bin/bash -c /usr/bin/cinder-manage db version',
        '/bin/bash -c /usr/bin/cinder-manage db sync',
        'service openstack-cinder-api restart',
        'service openstack-cinder-scheduler restart',
        'service openstack-cinder-volume restart',
        '/bin/bash -c /usr/bin/manila-manage db version',
        '/bin/bash -c /usr/bin/manila-manage db sync',
        'service openstack-manila-api restart',
        'service openstack-manila-scheduler restart',
        'service openstack-manila-share restart',
        '/usr/bin/nova-manage api_db sync',
        '/usr/bin/nova-manage cell_v2 map_cell0',
        '/usr/bin/nova-manage cell_v2 create_cell --name=cell1 --verbose',
        '/usr/bin/nova-manage cell_v2 discover_hosts --verbose',
        '/bin/bash -c /usr/bin/nova-manage db version',
        '/bin/bash -c /usr/bin/nova-manage db sync',
        'service openstack-nova-api restart',
        'service openstack-nova-consoleauth restart',
        'service openstack-nova-scheduler restart',
        'service openstack-nova-conductor restart',
        'service openstack-nova-novncproxy restart',
        '/bin/bash -c /usr/bin/neutron-db-manage current',
        '/bin/bash -c /usr/bin/neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head',
        'service neutron-dhcp-agent restart',
        'service neutron-l3-agent restart',
        'service neutron-linuxbridge-agent restart',
        'service neutron-metadata-agent restart',
        'service neutron-server restart',
        '/bin/bash -c /usr/bin/heat-manage db_version',
        '/bin/bash -c /usr/bin/heat-manage db_sync',
        'service openstack-heat-api restart',
        'service openstack-heat-api-cfn restart',
        'service openstack-heat-engine restart',
        '/bin/bash -c /usr/bin/murano-db-manage version',
        '/bin/bash -c /usr/bin/murano-db-manage upgrade',
        'service murano-api restart',
        'service murano-engine restart',
        '/usr/bin/gnocchi-upgrade',
        '/bin/bash -c /usr/bin/ceilometer-upgrade --version',
        '/bin/bash -c /usr/bin/ceilometer-upgrade --debug',
        'service openstack-gnocchi-metricd restart',
        'service httpd restart',
        'service openstack-ceilometer-notification restart',
        'service openstack-ceilometer-central restart',
        '/usr/bin/cloudkitty-storage-init',
        '/bin/bash -c /usr/bin/cloudkitty-dbsync version --module cloudkitty',
        '/bin/bash -c /usr/bin/cloudkitty-dbsync upgrade',
        'service cloudkitty-processor restart',
        'service httpd restart',
        '/bin/bash -c /usr/bin/magnum-db-manage version',
        '/bin/bash -c /usr/bin/magnum-db-manage upgrade',
        'service openstack-magnum-api restart',
        'service openstack-magnum-conductor restart',
        '/bin/bash -c /usr/bin/barbican-manage db version',
        '/bin/bash -c /usr/bin/barbican-manage db upgrade',
        'service httpd restart',
        'service httpd restart',
                      ]), "server expected commands run");

diag "method history";
dump_method_history;
ok(method_history_ok([
    'POST .*/v3/auth/tokens',
    'GET .*/regions/  ',
    'POST .*/regions/ .*description":"abc",.*"id":"regionOne"',
    'POST .*/regions/ .*description":"def",.*"id":"regionTwo"',
    'POST .*/regions/ .*description":"xyz",.*"id":"regionThree"',
    'GET .*/domains/  ',
    'POST .*/domains/ .*description":"vo1",.*"name":"vo1"',
    'POST .*/domains/ .*description":"vo2",.*"name":"vo2"',
    'GET .*/projects/  ',
    'POST .*/projects/ .*,"name":"opq"',
    'POST .*/projects/ .*"description":"main vo1 project","domain_id":"dom12345".*"name":"vo1"',
    'POST .*/projects/ .*"description":"main vo2 project","domain_id":"dom23456",.*"name":"vo2"',
    'POST .*/projects/ .*"description":"some real project".*"name":"realproject".*"parent_id":"pro124"',
    'GET .*/users/  ',

    'POST .*/users/ .*"description":"quattor service key-manager flavour barbican user","domain_id":"dom112233","enabled":true,"name":"barbican","password":"barbican_good_password"',
    'POST .*/users/ .*"description":"quattor service metric flavour ceilometer user","domain_id":"dom112233","enabled":true,"name":"ceilometer","password":"ceilometer_good_password"',
    'PUT .*/projects/10/tags/ID_user_use12ce',
    'POST .*/users/ .*"description":"quattor service volume flavour cinder user","domain_id":"dom112233","enabled":true,"name":"cinder","password":"cinder_good_password"',
    'PUT .*/projects/10/tags/ID_user_use12c',
    'POST .*/users/ .*"description":"quattor service rating flavour cloudkitty user","domain_id":"dom112233","enabled":true,"name":"cloudkitty","password":"cloudkitty_good_password"',
    'POST .*/users/ .*"description":"quattor service image flavour glance user","domain_id":"dom112233","enabled":true,"name":"glance","password":"glance_good_password"',
    'PUT .*/projects/10/tags/ID_user_use12g',
    'POST .*/users/ .*"description":"quattor service orchestration flavour heat user","domain_id":"dom112233","enabled":true,"name":"heat","password":"heat_good_password"',
    'POST .*/users/ .*"description":"quattor service container-infra flavour magnum user","domain_id":"dom112233","enabled":true,"name":"magnum","password":"magnum_good_password"',
    'POST .*/users/ .*"description":"quattor service share flavour manila user","domain_id":"dom112233","enabled":true,"name":"manila","password":"manila_good_password"',
    'POST .*/users/ .*"description":"quattor service catalog flavour murano user","domain_id":"dom112233","enabled":true,"name":"murano","password":"murano_good_password"',
    'POST .*/users/ .*"description":"quattor service network flavour neutron user","domain_id":"dom112233","enabled":true,"name":"neutron","password":"neutron_good_password"',
    'PUT .*/projects/10/tags/ID_user_use12m',
    'POST .*/users/ .*"description":"quattor service compute flavour nova user","domain_id":"dom112233","enabled":true,"name":"nova","password":"nova_good_password"',
    'POST .*/users/ .*"description":"first user",.*"name":"user1","password":"abc"',
    'GET .*/groups/  ',
    'POST .*/groups/ .*"description":"first group","domain_id":"dom23456",.*"name":"grp1"',
    'PUT .*/projects/10/tags/ID_group_use12',
    'GET .*/roles/  ',
    'POST .*/roles/ .*"enabled":true,"name":"rl1"',
    'PUT .*/projects/10/tags/ID_role_rll11',
    'POST .*/roles/ .*"enabled":true,"name":"rl2"',
    'PUT .*/projects/10/tags/ID_role_rll12',
    'PUT .*/domains/dom12345/users/use12/roles/rll11 \{\} ',
    'PUT .*/projects/10/tags/ROLE_ZG9tYWlucy9kb20xMjM0NS91c2Vycy91c2UxMi9yb2xlcy9ybGwxMQ \{\}',
    'PUT .*/projects/pro125/groups/use12/roles/rll12 \{\}',
    'PUT .*/projects/pros/users/use12c/roles/rolaaddmm ',
    'PUT .*/projects/pros/users/use12g/roles/rolaaddmm ',
    'PUT .*/projects/pros/users/use12m/roles/rolaaddmm ',
    'PUT .*/projects/pros/users/use12no/roles/rolaaddmm ',
    'GET .*/services/  ',
    'POST .*/services/ .*"description":"OS volumev2 service cinderv2",.*"name":"cinderv2","type":"volumev2"',
    'POST .*/services/ .*"description":"OS volumev3 service cinderv3",.*"name":"cinderv3","type":"volumev3"',
    'POST .*/services/ .*"description":"OS rating service cloudkitty",.*"name":"cloudkitty","type":"rating"',
    'POST .*/services/ .*"description":"OS compute service nova",.*"name":"nova","type":"compute"',
    'POST .*/services/ .*"description":"OS placement service placement",.*"name":"placement","type":"placement"',
    'GET .*/endpoints/  ',
    'POST .*/endpoints/ .*"interface":"admin","service_id":"serv111","url":"http://admin".*',
    'PUT .*/projects/10/tags/ID_endpoint_ept1 \{\}',
    'POST .*/endpoints/ .*"interface":"admin","service_id":"serv114","url":"https://openstack:35357/v3".*',
    'POST .*/endpoints/ .*"interface":"admin","service_id":"serv122","url":"https://openstack:8000/v1".* ',
    'POST .*/endpoints/ .*"interface":"admin","service_id":"serv116","url":"https://openstack:8004/v1/%\(tenant_id\)s".* ',
    'POST .*/endpoints/ .*"interface":"admin","service_id":"serv123","url":"https://openstack:8041/".* ',
    'POST .*/endpoints/ .*"interface":"admin","service_id":"serv117","url":"https://openstack:8082/".* ',
    'POST .*/endpoints/ .*"interface":"admin","service_id":"serv112","url":"https://openstack:8774/v2.1/%\(tenant_id\)s".* ',
    'POST .*/endpoints/ .*"interface":"admin","service_id":"serv118","url":"https://openstack:8776/v2/%\(project_id\)s".* ',
    'POST .*/endpoints/ .*"interface":"admin","service_id":"serv118b","url":"https://openstack:8776/v3/%\(project_id\)s".* ',
    'POST .*/endpoints/ .*"interface":"admin","service_id":"serv113","url":"https://openstack:8778/".* ',
    'POST .*/endpoints/ .*"interface":"admin","service_id":"serv120","url":"https://openstack:8786/v1/%\(tenant_id\)s".* ',
    'POST .*/endpoints/ .*"interface":"admin","service_id":"serv124","url":"https://openstack:8889/".* ',
    'POST .*/endpoints/ .*"interface":"admin","service_id":"serv115","url":"https://openstack:9292/".* ',
    'POST .*/endpoints/ .*"interface":"admin","service_id":"serv126","url":"https://openstack:9311/".* ',
    'POST .*/endpoints/ .*"interface":"admin","service_id":"serv125","url":"https://openstack:9511/v1".* ',
    'POST .*/endpoints/ .*"interface":"admin","service_id":"serv119","url":"https://openstack:9696/".* ',
    'POST .*/endpoints/ .*"interface":"internal","service_id":"serv111","url":"http://internal0".*',
    'POST .*/endpoints/ .*"interface":"internal","service_id":"serv111","url":"http://internal1".*',
]), "REST API calls as expected");

command_history_reset();
set_output('keystone_db_version');
ok($cmp->Configure($cfg), 'Configure returns success 2nd');
ok(!exists($cmp->{ERROR}), "No errors found in normal execution 2nd");

done_testing();
