declaration template metaconfig/fail2ban/schema_jail;


include 'pan/types';


type fail2ban_filter_logpath = {
    @{
    Path to the log file(s) which is provided to the filter.
    Globs -- paths containing * and ? or [0-9] -- can be used, however only the files that exist at start up
    matching this glob pattern will be considered.
    }
    'filepath' : absolute_file_path

    @{
    Cause the log file to be read from the end, the default 'head' option reads the file from the beginning
    }
    'tail' ? boolean
};


type fail2ban_jail_action = extensible {
    'name' : string_non_whitespace
};


type fail2ban_jail = {
    @{
        Name of the filter to be used by the jail to detect matches.
        (i.e. filename of the filter in /etc/fail2ban/filter.d/ without the .conf/.local extension.)
        Each single match by a filter increments the counter within the jail.
        Only one filter can be specified.
    }
    'filter' ? string_non_whitespace

    @{
        Log files to be monitored
    }
    'logpath' ? fail2ban_filter_logpath[]

    @{
        Encoding of log files used for decoding.
        Default uses current system locale.
    }
    'logencoding' ? string_non_whitespace

    @{
    banning action (default iptables-multiport) typically specified in the [DEFAULT] section for all jails.
    This parameter will be used by the standard substitution of action and can be redefined central in the [DEFAULT]
    section inside jail.local (to apply it to all jails at once) or separately in each jail, where this substitution
    will be used.
    }
    'banaction' ? string_non_whitespace

    @{
    the same as banaction but for some "allports" jails like "pam-generic" or "recidive" (default iptables-allports).
    }
    'banaction_allports' ? string_non_whitespace

    @{
    action(s) from /etc/fail2ban/action.d/ without the .conf/.local extension.
    The default values from the [Init] section in the action file can be overridden with additional key-value pairs.
    }
    'action' ? fail2ban_jail_action[]

    @{
    list of IPs not to ban.
    TODO: Can include CIDR masks
    }
    'ignoreip' ? type_ip[]

    @{
    Command that is executed to determine if the current candidate IP for banning should not be banned.
    IP will not be banned if command returns successfully (exit code 0).
    Like ACTION FILES, tags like <ip> are can be included in the ignorecommand value and will be substituted before execution.
    Currently only <ip> is supported.
    }
    'ignorecommand' ? absolute_file_path

    @{
        Duration (in seconds) for IP to be banned for.
        Negative number for "permanent" ban.
    }
    'bantime' ? long(-1..)

    @{
        The counter is set to zero if no match is found within "findtime" seconds.
    }
    'findtime' ? long(1..)

    @{
        Number of matches (i.e. value of the counter) which triggers ban action on the IP.
    }
    'maxretry' ? long(1..)
};

type fail2ban_jailfile = {
    'contents' : fail2ban_jail{}
};
