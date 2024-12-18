# ${license-info}
# ${developer-info}
# ${author-info}


declaration template components/openstack/common;

include 'components/openstack/functions';

type openstack_storagebackend = string with match(SELF, '^(file|http|swift|rbd|sheepdog|cinder|vmware)$');

type openstack_neutrondriver = string with match(SELF, '^(local|flat|vlan|gre|vxlan|geneve)$');

type openstack_neutronextension = string with match(SELF, '^(qos|port_security)$');

type openstack_valid_region = string with openstack_is_valid_identity(SELF, 'region');

type openstack_tunnel_types = string with match(SELF, '^(vxlan|gre)$');

type openstack_neutron_mechanism_drivers = string with match(SELF, '^(linuxbridge|l2population|openvswitch)$');

type openstack_neutron_firewall_driver = string with match(SELF,
    '^(neutron.agent.linux.iptables_firewall.IptablesFirewallDriver|openvswitch|iptables_hybrid|iptables)$'
);

type openstack_share_backends = string with match(SELF, '^(lvm|generic|cephfsnative|cephfsnfs)$');

type openstack_share_protocols = string with match(SELF, '^(NFS|CIFS|CEPHFS|GLUSTERFS|HDFS|MAPRFS)$');

type openstack_neutron_service_plugins = choice('router', 'port_forwarding')[];

type openstack_neutron_agent_extensions = choice('port_forwarding')[];

type openstack_keystone_endpoint_type = choice('internalURL', 'publicURL');

@documentation{
    OpenStack common domains section
}
type openstack_domains_common = {
    @{Domain name containing project}
    'project_domain_name' : string = 'Default'
    @{Project name to scope to}
    'project_name' : string = 'service'
    @{The type of authentication credential to create.
    Required if no context is passed to the credential factory}
    'auth_type' : string = 'password' with match (SELF, '^(password|token|keystone_token|keystone_password)$')
    @{Users domain name}
    'user_domain_name' : string = 'Default'
    @{Keystone authentication URL http(s)://host:port}
    'auth_url' : type_absoluteURI
    @{OpenStack service username}
    'username' : string
    @{OpenStack service user password}
    'password' : string
    @{Type of endpoint in Identity service catalog to use for communication with
    OpenStack services}
    'interface' ? openstack_keystone_endpoint_type = 'internalURL'
};

@documentation{
    OpenStack common region section
}
type openstack_region_common = {
    'os_region_name' : string = 'RegionOne'
};

@documentation{
    The configuration options in the database Section
}
type openstack_database = {
    @{The SQLAlchemy connection string to use to connect to the database}
    'connection' : string
};

@documentation{
    The configuration options in 'oslo_concurrency' Section.
}
type openstack_oslo_concurrency = {
    @{Directory to use for lock files.  For security, the specified directory should
    only be writable by the user running the processes that need locking. Defaults
    to environment variable OSLO_LOCK_PATH. If external locks are used, a lock
    path must be set}
    'lock_path' : absolute_file_path
};

@documentation{
    The configuration options in 'oslo_messaging_notifications' Section.
}
type openstack_oslo_messaging_notifications = {
    @{The drivers to handle sending notifications}
    'driver' : choice('messaging', 'messagingv2', 'routing', 'log', 'test', 'noop') = 'messagingv2'
};

@documentation{
    The configuration options in the DEFAULTS Section
}
type openstack_DEFAULTS = {
    @{Using this feature is *NOT* recommended. Instead, use the "keystone-manage
    bootstrap" command. The value of this option is treated as a "shared secret"
    that can be used to bootstrap Keystone through the API. This "token" does not
    represent a user (it has no identity), and carries no explicit authorization
    (it effectively bypasses most authorization checks). If set to "None", the
    value is ignored and the "admin_token" middleware is effectively disabled.
    However, to completely disable "admin_token" in production (highly
    recommended, as it presents a security risk), remove
    AdminTokenAuthMiddleware (the "admin_token_auth" filter) from your paste
    application pipelines (for example, in "keystone-paste.ini")}
    'admin_token' ? string
    'notifications' ? string
    @{From oslo.log
    If set to true, the logging level will be set to DEBUG instead of the default
    INFO level.
    Note: This option can be changed without restarting}
    'debug' ? boolean
    @{Use syslog for logging. Existing syslog format is DEPRECATED and will be
    changed later to honor RFC5424. This option is ignored if log_config_append
    is set}
    'use_syslog' ? boolean
    @{Syslog facility to receive log lines. This option is ignored if
    log_config_append is set}
    'syslog_log_facility' ? string
    @{From nova.conf
    This determines the strategy to use for authentication: keystone or noauth2.
    "noauth2" is designed for testing only, as it does no actual credential
    checking. "noauth2" provides administrative credentials only if "admin" is
    specified as the username}
    'auth_strategy' ? string = 'keystone' with match (SELF, '^(keystone|noauth2)$')
    @{From nova.conf
    The IP address which the host is using to connect to the management network.
    Default is IPv4 address of this host}
    'my_ip' ? type_ip
    @{From nova.conf
    List of APIs to be enabled by default}
    'enabled_apis' ? string[] = list('osapi_compute', 'metadata')
    @{From cinder.conf
    Top-level directory for maintaining cinder state}
    'state_path' ? absolute_file_path = '/var/lib/cinder'
    @{From glance.conf
    A list of backend names to use. These backend names should be backed by a
    unique [CONFIG] group with its options}
    'enabled_backends' ? string[]
    @{From glance.conf
    A list of the URLs of glance API servers available to cinder}
    'glance_api_servers' ? type_absoluteURI[]
    @{From nova.conf
    An URL representing the messaging driver to use and its full configuration.
    Example: rabbit://openstack:<rabbit_password>@<fqdn>
    }
    'transport_url' ? string
    @{Path to the rootwrap configuration file.

    Goal of the root wrapper is to allow a service-specific unprivileged user to
    run a number of actions as the root user in the safest manner possible.
    The configuration file used here must match the one defined in the sudoers
    entry.

    Be sure to include into sudoers these lines:
        nova ALL = (root) NOPASSWD: /usr/bin/nova-rootwrap /etc/nova/rootwrap.conf *
    more info https://wiki.openstack.org/wiki/Rootwrap}
    'rootwrap_config' ? absolute_file_path
    @{From neutron.conf
    The core plugin Neutron will use}
    'core_plugin' ? string = 'ml2'
    @{From neutron.conf
    The service plugins Neutron will use}
    'service_plugins' ? openstack_neutron_service_plugins = list('router')
    @{From neutron.conf
    Allow overlapping IP support in Neutron. Attention: the following parameter
    MUST be set to False if Neutron is being used in conjunction with Nova
    security groups}
    'allow_overlapping_ips' ? boolean = true
    @{From neutron.conf
    Send notification to nova when port status changes}
    'notify_nova_on_port_status_changes' ? boolean = true
    @{From neutron.conf
    Send notification to nova when port data (fixed_ips/floatingip) changes so
    nova can update its cache}
    'notify_nova_on_port_data_changes' ? boolean = true
    @{From Neutron l3_agent.ini and dhcp_agent.ini
    The driver used to manage the virtual interface}
    'interface_driver' ? string = 'linuxbridge' with match (SELF, '^(linuxbridge|openvswitch)$')
    @{From Neutron dhcp_agent.ini
    The driver used to manage the DHCP server}
    'dhcp_driver' ? string = 'neutron.agent.linux.dhcp.Dnsmasq'
    @{Number of DHCP agents scheduled to host a tenant network. If this number is
    greater than 1, the scheduler automatically assigns multiple DHCP agents for
    a given tenant network, providing high availability for DHCP service}
    'dhcp_agents_per_network' ? long(1..)
    @{From Neutron dhcp_agent.ini
    The DHCP server can assist with providing metadata support on isolated
    networks. Setting this value to True will cause the DHCP server to append
    specific host routes to the DHCP request. The metadata service will only be
    activated when the subnet does not contain any router port. The guest
    instance must be configured to request host routes via DHCP (Option 121).
    This option does not have any effect when force_metadata is set to True}
    'enable_isolated_metadata' ? boolean = true
    @{From Neutron dhcp_agent.ini
    In some cases the Neutron router is not present to provide the metadata IP
    but the DHCP server can be used to provide this info. Setting this value will
    force the DHCP server to append specific host routes to the DHCP request. If
    this option is set, then the metadata service will be activated for all the
    networks}
    'force_metadata' ? boolean = true
    @{From Neutron metadata_agent.ini
    When proxying metadata requests, Neutron signs the Instance-ID header with a
    shared secret to prevent spoofing. You may select any string for a secret,
    but it must match here and in the configuration used by the Nova Metadata
    Server. NOTE: Nova uses the same config key, but in [neutron] section}
    'metadata_proxy_shared_secret' ? string
    @{From Neutron metadata_agent.ini
    IP address or DNS name of Nova metadata server}
    'nova_metadata_host' ? string
    @{Driver for security groups}
    'firewall_driver' ? string = 'neutron.agent.linux.iptables_firewall.IptablesFirewallDriver'
    @{Use neutron and disable the default firewall setup}
    'use_neutron' ? boolean = true
    @{From manila.conf
    Default share type to use.
    The default_share_type option specifies the default share type to be used
    when shares are created without specifying the share type in the request.
    The default share type that is specified in the configuration file has to
    be created with the necessary required extra-specs
    (such as driver_handles_share_servers) set appropriately with reference to
    the driver mode used}
    'default_share_type' ? string = 'default'
    @{From manila.conf
    Template string to be used to generate share names}
    'share_name_template' ? string = 'share-%s'
    @{From manila.conf
    File name for the paste.deploy config for manila-api}
    'api_paste_config' ? absolute_file_path = '/etc/manila/api-paste.ini'
    @{From manila.conf
    A list of share backend names to use. These backend names should be
    backed by a unique [CONFIG] group with its options}
    'enabled_share_backends' ? openstack_share_backends[] = list('lvm')
    @{From manila.conf
    Specify list of protocols to be allowed for share creation}
    'enabled_share_protocols' ? openstack_share_protocols[] = list('NFS')
};

@documentation{
    The configuration options for CORS middleware.
    This middleware provides a comprehensive, configurable
    implementation of the CORS (Cross Origin Resource Sharing)
    specification as oslo-supported python wsgi middleware.
}
type openstack_cors = {
    @{Indicate whether this resource may be shared with the domain
    received in the requests "origin" header.
    Format: "<protocol>://<host>[:<port>]", no trailing slash.
    Example: https://horizon.example.com}
    'allowed_origin' : type_absoluteURI[]
    @{Maximum cache age of CORS preflight requests}
    'max_age' ? long(1..) = 3600
    @{Indicate that the actual request can include user credentials}
    'allow_credentials' ? boolean
};

type openstack_quattor_endpoint = {
    @{endpoint host (proto://host:port/suffix)}
    'host' ? type_hostname
    @{endpoint protocol (proto://host:port/suffix)}
    'proto' ? choice('http', 'https')
    @{endpoint port (proto://host:port/suffix) (mandatory for internal endpoint)}
    'port' ? type_port
    @{endpoint suffix (proto://host:port/suffix)}
    'suffix' ? string
    @{region that the service/endpoint belongs to}
    'region' ? openstack_valid_region
};

type openstack_quattor_service_common = {
    @{public endpoint (on top of internal endpoint configuration)}
    'public' ? openstack_quattor_endpoint
    @{admin endpoint (on top of internal endpoint configuration)}
    'admin' ? openstack_quattor_endpoint
};


type openstack_quattor_service = {
    include openstack_quattor_service_common
    @{internal endpoint (is also default for public and/or admin)}
    'internal' : openstack_quattor_endpoint with {
        foreach (i; attr; list('host', 'port')) {
            if (!exists(SELF[attr])) {
                error('openstack quattor internal (endpoint) must have %s defined', attr);
            };
        };
        true;
    }
    @{service name (default is current openstack flavour name)}
    'name' ? string
    @{service type (default is current openstack service name)}
    'type' ? string
};

type openstack_quattor_service_extra = {
    include openstack_quattor_service_common
    @{internal endpoint (is also default for public and/or admin)}
    'internal' : openstack_quattor_endpoint with {
        foreach (i; attr; list('port')) {
            if (!exists(SELF[attr])) {
                error('openstack quattor internal (extra endpoint) must have %s defined', attr);
            };
        };
        true;
    }
    'type' : string
};


@documentation{
Custom configuration type. This is data that is not picked up as configuration data,
but used to e.g. build up the service endpoints.
(Any section named quattor is also not rendered)

It is to be used as e.g.
    type openstack_quattor_servicex = openstack_quattor = dict('quattor', dict('port', 123))

And then this custom service type is included in the service configuration.
    type openstack_servicex = {
        'quattor' : openstack_quattor_servicex
        ...
}
type openstack_quattor = {
    @{default service/endpoint}
    'service' ? openstack_quattor_service
    @{other services; key is name. Default values like public/internal are taken from service}
    'services' ? openstack_quattor_service_extra{}
} with {
    if (exists(SELF['services']) && !exists(SELF['service'])) {
        error("openstack quattor service configuration when configuring (other) services");
    };
    true;
};
