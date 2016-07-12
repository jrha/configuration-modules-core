# ${license-info}
# ${developer-info}
# ${author-info}

declaration template components/spma/yum/schema;

include 'components/spma/schema-common';

type SOFTWARE_GROUP = {
    "default" : boolean = true
    "mandatory" : boolean = true
    "optional" : boolean = false
};

type spma_yum_plugin_fastestmirror = {
    'enabled' : boolean = false
    'verbose' : boolean = false
    'always_print_best_host' : boolean = true
    'socket_timeout' : long(0..) = 3
    'hostfilepath' : string = "timedhosts.txt"
    'maxhostfileage' : long(0..) = 10
    'maxthreads' : long(0..) = 15
    'exclude' ? string[]
    'include_only' ? string[]
};

type spma_yum_plugin_versionlock = {
    'enabled' : boolean = true
    'locklist' : string = '/etc/yum/pluginconf.d/versionlock.list'
    'follow_obsoletes' ? boolean
};

type spma_yum_plugin_priorities = {
    'enabled' : boolean = true
    'check_obsoletes' ? boolean
};

type spma_yum_plugins = {
    "fastestmirror" ? spma_yum_plugin_fastestmirror
    "versionlock" ? spma_yum_plugin_versionlock
    "priorities" ? spma_yum_plugin_priorities
};

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
    include component_spma_type
    "userpkgs_retry" : boolean = true
    "fullsearch" : boolean = false
    "excludes"      ? string[] # packages to be excluded from metadata
    "yumconf"       ? string # /etc/yum.conf YUM configuration
    "whitelist"     ? string[] # packages not shipped by repositories but generated by 3rd party installer
    "quattor_os_file" ? string # file to write quattor_os_release as confirmation of successful YUM spma pass
    "quattor_os_release" ? string # string to write to quattor_os_file
    "suffix"        ? string # suffix of alternative packaging module to include instead of standard one
    "plugins" ? spma_yum_plugins
    "main_options" ? spma_yum_main_options
};

bind "/software/components/spma" = component_spma_yum;
bind "/software/groups" = SOFTWARE_GROUP{};
