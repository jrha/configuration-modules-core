# ${license-info}
# ${developer-info}
# ${author-info}

declaration template components/spma/yum/schema;

include 'components/spma/schema';
include 'components/spma/schema-common-yum';

@documentation{
    Main configuration options for yum.conf.
    The cleanup_on_remove, obsoletes, reposdir and pluginpath are set internally.
}
type spma_yum_main_options = {
    "exclude" ? string[]
    "installonly_limit" ? long(0..) = 3
    "keepcache" ? boolean
    "retries" ? long(0..) = 10
    "timeout" ? long(0..) = 30
};

type component_spma_yum = {
    include structure_component
    include component_spma_common
    include component_spma_common_yum
    "fullsearch" : boolean = false
    "main_options" ? spma_yum_main_options
    "plugins" ? spma_yum_plugins
    "process_obsoletes" : boolean = false
    "proxytype" ? string with match (SELF, '^(forward|reverse)$') # select proxy type, forward or reverse
    "userpkgs_retry" : boolean = true
};

bind "/software/components/spma" = component_spma_yum;
