object template config;

include 'metaconfig/singularity/config';

prefix "/software/components/metaconfig/services/{/etc/singularity/singularity.conf}/contents";
"enable/overlay" = true;
"bind/path" = list("/my/scratch", "/etc/singularity/default-nsswitch.conf:/etc/nsswitch.conf");
"limit/container/owners" = list("singularity", "nobody");
"limit/container/paths" = list("/local/scratch", "/tmp");
