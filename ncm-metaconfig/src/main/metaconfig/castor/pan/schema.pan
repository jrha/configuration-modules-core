template features/castor/castor-conf/macroheadnode/schema;

include 'pan/types';

type castor_conf_client = {
    'HIGHPORT' : type_port
    'LOWPORT' : type_port
};

type castor_conf_cns = {
    'CONRETRY' : long
    'CONRETRYINT' : long
};

type castor_conf_csec = {
    'DISABLE' : string with match(SELF, '^YES|NO$')
};

type castor_conf_diskmanager = {
    'ServerHosts' : type_hostname[]
};

type castor_conf_rh = {
    'HOST' : type_hostname
    'SRMHostsList' : type_hostname[]
};

type castor_conf_stager = {
    'HOST' : type_hostname
    'NOTIFYHOST' : type_hostname
    'NOTIFYPORT' : type_port
};

type castor_conf_tapegateway = {
    'MINWORKERTHREADS' : long(1..)
    'MAXWORKERTHREADS' : long(1..)
} with {
    if (SELF['MINWORKERTHREADS'] > SELF['MAXWORKERTHREADS']) {
        error ('MINWORKERTHREADS must be less than MAXWORKERTHREADS')
    };
    true;
}

type castor_conf_upv = {
    'HOST' : type_hostname
};

type castor_conf_vdqm = {
    'HOST' : type_hostname
};

type castor_conf_vmgr = {
    'HOST' : type_hostname
};

type castor_conf = {
    'CLIENT' ? castor_conf_client
    'CNS' ? castor_conf_cns
    'CSEC' ? castor_conf_csec
    'DiskManager' ? castor_conf_diskmanager
    'RH' ? castor_conf_rh
    'STAGER' ? castor_conf_stager
    'TAPEGATEWAY' ? castor_conf_tapegateway
    'UPV' ? castor_conf_upv
    'VDQM' ? castor_conf_vdqm
    'VMGR' ? castor_conf_vmgr
};
