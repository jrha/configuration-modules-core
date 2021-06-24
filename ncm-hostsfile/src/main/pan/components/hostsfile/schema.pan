# ${license-info}
# ${developer-info}
# ${author-info}

############################################################
#
# type definition components/hostsfile
#
#
#
############################################################

declaration template components/hostsfile/schema;

include 'quattor/schema';

type hostsfile_entry = {
    "ipaddr" : type_ip
    "aliases" ? string_trimmed
    "comment" ? string_trimmed
};

type component_hostsfile_type = {
    include structure_component
    "file" ? string        # File to store in.  Default is /etc/hosts
    "entries" : hostsfile_entry{} with {
        foreach (k; v; SELF) {
            if (! is_fqdn(k)) error('Invalid FQDN "%s" for hostfile entry', k);
        };
        true;
    };
    "takeover" : boolean = false
};

bind "/software/components/hostsfile" = component_hostsfile_type;
