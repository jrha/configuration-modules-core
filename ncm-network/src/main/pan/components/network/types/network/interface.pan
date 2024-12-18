declaration template components/network/types/network/interface;

@{Generate error if network backend is not supported.
  First argument is the component backend (ncm-module).
  Optional 2nd is extra message
}
function network_exclude_backend = {
    module = value('/software/components/network/ncm-module', '');
    msg = if (ARGC < 2) '' else format(': %s', ARGV[1]);
    if (module == ARGV[0]) {
        error("Not supported in backend module %s%s", module, msg)
    };
    true;
};

include 'components/network/types/network/ethtool';
include 'components/network/types/network/route';
include 'components/network/types/network/rule';
include 'components/network/types/network/ovs';
include 'components/network/types/network/tunnel';


@documentation{
    Interface alias
}
type network_interface_alias = {
    "ip" ? type_ip
    "netmask" : type_ip
    "broadcast" ? type_ip
    "fqdn" ? type_fqdn
};

@documentation{
    Describes the bonding options for configuring channel bonding on EL and similar.
    Used by initscripts and nmstate backend.
    As per https://docs.rs/nmstate/latest/nmstate/struct.BondOptions.html#fields
}
type network_bonding_options = {
    @{802.3ad aggregation selection logic}
    "ad_select"         ? choice('bandwidth', 'count', 'stable')
    @{Drop (0) or deliver(1) duplicate frames on inactive ports}
    "all_slaves_active" ? long(0..1)
    @{ARP link monitoring frequency in milliseconds}
    "arp_interval"      ? long(0..)
    @{IP addresses to use as ARP monitoring peers when arp_interval is > 0}
    "arp_ip_target"     ? type_ip[]
    @{For which ports should ARP probes and replies should be validated or ignored completely}
    "arp_validate"      ? choice('none', 'active', 'backup', 'all')
    @{Milliseconds to wait before disabling a port after a link failure has been detected by miimon}
    "downdelay"         ? long(0..)
    @{MAC address assignment policy for failover bonds}
    "fail_over_mac"     ? choice('active', 'follow', 'none')
    @{Requested LACPDU packet rate in 802.3ad mode}
    "lacp_rate"         ? long(0..1)
    @{Minimum number of links that must be active before asserting carrier}
    "min_links"         ? long(0..)
    @{Milliseconds between link state checks}
    "miimon"            ? long(0..)
    "mode"              : long(0..6)
    @{Number of gratuitous ARPs after failover}
    "num_grat_arp"      ? long(0..255)
    @{Number of unsolicited IPv6 Neighbor Advertisements after failover}
    "num_unsol_na"      ? long(0..255)
    @{Which interface is considered the primary device}
    "primary"           ? valid_interface
    @{Method used to choose a new primary when the primary fails}
    "primary_reselect"  ? choice('always', 'better', 'failure')
    @{Number of IGMP membership reports sent after failover}
    "resend_igmp"       ? long(0..255)
    @{Use link state from the device driver}
    "use_carrier"       ? boolean
    @{Milliseconds to wait before enabling a port after link recovery}
    "updelay"           ? long(0..)
    @{Transmit hash policy used in balance-xor, 802.3ad and tlb modes}
    "xmit_hash_policy"  ? choice('0', '1', '2', 'layer2', 'layer2+3', 'layer3+4')
} with {
    if ( SELF['mode'] == 1 || SELF['mode'] == 5 || SELF['mode'] == 6 ) {
        if ( ! exists(SELF["primary"]) ) {
            error("Bonding configured but no primary is defined.");
        };
    } else {
        if ( exists(SELF["primary"]) ) {
            error("Primary is defined but this is not allowed with this bonding mode.");
        };
    };
    true;
};

@documentation{
    describes the bridging options
    (the parameters for /sys/class/net/<br>/brport)
}
type network_bridging_options = {
    "bpdu_guard" ? long
    "flush" ? long
    "hairpin_mode" ? long
    "multicast_fast_leave" ? long
    "multicast_router" ? long
    "path_cost" ? long
    "priority" ? long
    "root_block" ? long
};


type network_interface_type = choice(
    'Ethernet', 'Bridge', 'Tap', 'xDSL', 'IPIP', 'Infiniband',
    'OVSBridge', 'OVSPort', 'OVSIntPort', 'OVSBond', 'OVSTunnel', 'OVSPatchPort'
);

@documentation{
    network interface
}
type network_interface = {
    "ip" ? type_ip
    "gateway" ? type_ip
    "netmask" ? type_ip
    "broadcast" ? type_ip
    "driver" ? string
    "bootproto" ? choice('static', 'bootp', 'dhcp', 'none')
    "onboot" ? boolean
    "type" ? network_interface_type
    "device" ? string
    "mtu" ? long
    "master" ? string
    "bonding_opts" ? network_bonding_options
    @{Routes for this interface.
      These values are used to generate the /etc/sysconfig/network-scripts/route[6]-<interface> files
      as used by ifup-routes when using ncm-network.
      This allows for mixed IPv4 and IPv6 configuration}
    "route" ? network_route[]
    @{Rules for this interface.
      These values are used to generate the /etc/sysconfig/network-scripts/rule[6]-<interface> files
      as used by ifup-routes when using ncm-network.
      This allows for mixed IPv4 and IPv6 configuration}
    "rule" ? network_rule[]
    @{Aliases for this interface.
      These values are used to generate the /etc/sysconfig/network-scripts/ifcfg-<interface>:<key> files
      as used by ifup-aliases when using ncm-network.}
    "aliases" ? network_interface_alias{}
    @{Explicitly set the MAC address. The MAC address is taken from /hardware/cards/nic/<interface>/hwaddr.}
    "set_hwaddr" ? boolean


    @{Is a VLAN device. If the device name starts with vlan, this is always true.}
    "vlan" ? boolean
    @{If the device name starts with vlan, this has to be set.
      It is set (but ignored by ifup) if it the device is not named vlan}
    "physdev" ? valid_interface

    "fqdn" ? string
    "network_environment" ? string
    "network_type" ? string
    "nmcontrolled" ? boolean
    @{Set DEFROUTE, is the default for ipv6_defroute}
    "defroute" ? boolean

    "bridge" ? valid_interface
    "linkdelay" ? long # LINKDELAY
    "stp" ? boolean # enable/disable stp on bridge (true: STP=on)
    "delay" ? long # brctl setfd DELAY
    "bridging_opts" ? network_bridging_options

    "bond_ifaces" ? string[]

    "ipv4_failure_fatal" ? boolean
    "ipv6_autoconf" ? boolean
    "ipv6_failure_fatal" ? boolean
    "ipv6_mtu" ? long(1280..65536)
    "ipv6_privacy" ? choice('rfc3041')
    "ipv6_rtr" ? boolean
    @{Set IPV6_DEFROUTE, defaults to defroute value}
    "ipv6_defroute" ? boolean
    "ipv6addr" ? type_network_name
    "ipv6addr_secondaries" ? type_network_name[]
    "ipv6init" ? boolean

    include network_interface_ethtool
    include network_interface_ovs
    include network_interface_tunnel
} with {
    network_interface_ovs_validate(SELF);
    network_interface_tunnel_validate(SELF);

    if ( exists(SELF['bond_ifaces']) ) {
        foreach (i; iface; SELF['bond_ifaces']) {
            if ( !exists("/system/network/interfaces/" + iface) ) {
                error("The " + iface + " interface is used by bond_ifaces, but does not exist");
            };
        };
    };
    if (exists(SELF['ip']) && exists(SELF['netmask'])) {
        if (exists(SELF['gateway']) && ! ip_in_network(SELF['gateway'], SELF['ip'], SELF['netmask'])) {
            error('networkinterface has gateway %s not reachable from ip %s with netmask %s',
            SELF['gateway'], SELF['ip'], SELF['netmask']);
        };
        if (exists(SELF['broadcast']) && ! ip_in_network(SELF['broadcast'], SELF['ip'], SELF['netmask'])) {
            error('networkinterface has broadcast %s not reachable from ip %s with netmask %s',
            SELF['broadcast'], SELF['ip'], SELF['netmask']);
        };
    };

    true;
};
