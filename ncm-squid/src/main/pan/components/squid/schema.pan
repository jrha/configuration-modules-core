# ${license-info}
# ${developer-info}
# ${author-info}


declaration template components/squid/schema;

include {'quattor/schema'};
include {'pan/types'};

# Parameter structure for 'acl' directives
type structure_acl = {
    "name"          : string
    "type"          : string
    "targets"       : string[1..]
};

# Parameter structure for 'cache_dir' directives
type structure_cache_dir = {
    "type"          : string with match(SELF, '^(ufs|aufs|diskd)$')
    "directory"     : string with match(SELF, '^\/')
    "MBsize"        : long with SELF > 0
    "level1"        : long with SELF > 0
    "level2"        : long with SELF > 0
};

# Parameter structure for 'http_access' directives
type structure_http_access = {
    "policy"        : string with match(SELF, '^(allow|deny)$')
    "acls"          : string[1..]
};

# Parameter structure for 'refresh_pattern' directives
type structure_refresh_pattern = {
    "pattern"       : string
    "min"           : long with SELF >= 0
    "percent"       : long with SELF >= 0
    "max"           : long with SELF >= 0
};

# Set of basic two-token directives which should appear only once
type squid_basic_options_type = {
    "emulate_httpd_log"             ? string with match(SELF, '^(off|on)$')
    "http_port"                     ? long with SELF > 0 && SELF <= 65535
    "httpd_accel_host"              ? string
    "httpd_accel_port"              ? long with SELF > 0 && SELF <= 65535
    "httpd_accel_single_host"       ? string with match(SELF, '^(off|on)$')
    "httpd_accel_uses_host_header"  ? string with match(SELF, '^(off|on)$')
    "ignore_unknown_nameservers"    ? string with match(SELF, '^(off|on)$')
    "log_fqdn"                      ? string with match(SELF, '^(off|on)$')
    "negative_dns_ttl"              ? string with match(SELF, '^\d+\s+(seconds|minutes|hours|days)$')
    "redirect_rewrites_host_header" ? string with match(SELF, '^(off|on)$')
    "store_objects_per_bucket"      ? long with SELF > 0
};

# Set of directives affecting the cache size and which should appear only once.
# The size unit is *always* KB!
type squid_size_options_type = {
    "cache_mem"                     ? long with SELF > 0
    "maximum_object_size"           ? long with SELF > 0
    "maximum_object_size_in_memory" ? long with SELF > 0
    "range_offset_limit"            ? long with SELF >= -1
    "store_avg_object_size"         ? long with SELF > 0
};

# Set of multi-token directives which may appear more than once
type squid_multi_options_type = {
    "acl"                           : structure_acl[1..]
    "cache_dir"                     ? structure_cache_dir[]
    "dns_nameservers"               ? type_ipv4[1..]
    "http_access"                   : structure_http_access[1..]
    "refresh_pattern"               ? structure_refresh_pattern[]
};

type component_squid_type = {
    include structure_component
    "basic"     ? squid_basic_options_type
    "size"      ? squid_size_options_type
    "multi"     : squid_multi_options_type
};

bind "/software/components/squid" = component_squid_type;
