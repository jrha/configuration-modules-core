# ${license-info}
# ${developer-info}
# ${author-info}


declaration template components/ssh/schema;

include 'quattor/types/component';
include 'pan/types';

type ssh_preferred_authentication = string with match(SELF, '^(gssapi-with-mic|hostbased|publickey|keyboard-interactive|password)$');

type ssh_core_options_type = {
    "AddressFamily"                     ? string with match (SELF, '^(any|inet6?)$')
    "ChallengeResponseAuthentication"   ? transitional_yes_no_true_false
    "Ciphers"                           ? string
    "Compression"                       ? string with match (SELF, '^(yes|delayed|no)$')
    "GSSAPIAuthentication"              ? transitional_yes_no_true_false
    "GSSAPICleanupCredentials"          ? transitional_yes_no_true_false
    "GSSAPIKeyExchange"                 ? transitional_yes_no_true_false
    "GatewayPorts"                      ? transitional_yes_no_true_false
    "HostbasedAuthentication"           ? transitional_yes_no_true_false
    "LogLevel"                          ? string with match (SELF, '^(QUIET|FATAL|ERROR|INFO|VERBOSE|DEBUG[123]?)$')
    "MACs"                              ? string
    "PasswordAuthentication"            ? transitional_yes_no_true_false
    "Protocol"                          ? string
    "PubkeyAuthentication"              ? transitional_yes_no_true_false
    "RSAAuthentication"                 ? transitional_yes_no_true_false
    "RhostsRSAAuthentication"           ? transitional_yes_no_true_false
    "SendEnv"                           ? transitional_yes_no_true_false
    "TCPKeepAlive"                      ? transitional_yes_no_true_false
    "XAuthLocation"                     ? string
};

type ssh_daemon_options_type = {
    include ssh_core_options_type
    "AFSTokenPassing"                   ? transitional_yes_no_true_false
    @{AcceptEnv, one per line}
    "AcceptEnv"                         ? string[]
    "AllowAgentForwarding"              ? transitional_yes_no_true_false
    "AllowGroups"                       ? string
    "AllowTcpForwarding"                ? transitional_yes_no_true_false
    "AllowUsers"                        ? string
    "AuthorizedKeysFile"                ? string
    "AuthorizedKeysCommand"             ? string
    "AuthorizedKeysCommandRunAs"        ? string
    "Banner"                            ? string
    "ClientAliveCountMax"               ? long
    "ClientAliveInterval"               ? long
    "DenyGroups"                        ? string
    "DenyUsers"                         ? string
    "GSSAPIStrictAcceptorCheck"         ? transitional_yes_no_true_false
    @{HostKey, one per line}
    "HostKey"                           ? string[]
    "HPNDisabled"                       ? transitional_yes_no_true_false
    "HPNBufferSize"                     ? long
    "IgnoreRhosts"                      ? transitional_yes_no_true_false
    "IgnoreUserKnownHosts"              ? transitional_yes_no_true_false
    "KbdInteractiveAuthentication"      ? transitional_yes_no_true_false
    "KerberosAuthentication"            ? transitional_yes_no_true_false
    "KerberosGetAFSToken"               ? transitional_yes_no_true_false
    "KerberosOrLocalPasswd"             ? transitional_yes_no_true_false
    "KerberosTgtPassing"                ? transitional_yes_no_true_false
    "KerberosTicketAuthentication"      ? transitional_yes_no_true_false
    "KerberosTicketCleanup"             ? transitional_yes_no_true_false
    "KeyRegenerationInterval"           ? long
    @{ListenAddress, one per line}
    "ListenAddress"                     ? type_hostport[]
    "LoginGraceTime"                    ? long
    "MaxAuthTries"                      ? long
    "MaxStartups"                       ? long
    "NoneEnabled"                       ? transitional_yes_no_true_false
    "PermitEmptyPasswords"              ? transitional_yes_no_true_false
    "PermitRootLogin"                   ? string with match (SELF, '^(yes|without-password|forced-commands-only|no)$')
    "PermitTunnel"                      ? string with match (SELF, '^(yes|point-to-point|ethernet|no)$')
    "PermitUserEnvironment"             ? transitional_yes_no_true_false
    "PidFile"                           ? string
    "Port"                              ? long
    "PrintLastLog"                      ? transitional_yes_no_true_false
    "PrintMotd"                         ? transitional_yes_no_true_false
    "RhostsAuthentication"              ? transitional_yes_no_true_false
    "ServerKeyBits"                     ? long
    "ShowPatchLevel"                    ? transitional_yes_no_true_false
    "StrictModes"                       ? transitional_yes_no_true_false
    "Subsystem"                         ? string
    "SyslogFacility"                    ? string with match (SELF, '^(AUTH(PRIV)?|DAEMON|USER|KERN|UUCP|NEWS|MAIL|SYSLOG|LPR|FTP|CRON|LOCAL[0-7])$')
    "TcpRcvBuf"                         ? long
    "TcpRcvBufPoll"                     ? transitional_yes_no_true_false
    "UseDNS"                            ? transitional_yes_no_true_false
    "UseLogin"                          ? transitional_yes_no_true_false
    "UsePAM"                            ? transitional_yes_no_true_false
    "UsePrivilegeSeparation"            ? transitional_yes_no_true_false
    "VerifyReverseMapping"              ? transitional_yes_no_true_false
    "X11DisplayOffset"                  ? long
    "X11Forwarding"                     ? transitional_yes_no_true_false
    "X11UseLocalhost"                   ? transitional_yes_no_true_false
};

type ssh_client_options_type = {
    include ssh_core_options_type
    "BatchMode"                         ? transitional_yes_no_true_false
    "ConnectTimeout"                    ? long
    "EnableSSHKeysign"                  ? transitional_yes_no_true_false
    "ForwardAgent"                      ? transitional_yes_no_true_false
    "ForwardX11"                        ? transitional_yes_no_true_false
    "GSSAPIDelegateCredentials"         ? transitional_yes_no_true_false
    "Port"                              ? long
    "PreferredAuthentications"          ? ssh_preferred_authentication[]
    "RhostsAuthentication"              ? transitional_yes_no_true_false
    "StrictHostKeyChecking"             ? transitional_yes_no_true_false
    "UsePrivilegedPort"                 ? transitional_yes_no_true_false
};

type ssh_daemon_type = {
    "options" ? ssh_daemon_options_type
    "comment_options" ? ssh_daemon_options_type
    "sshd_path" ? string
    @{if false and sshd doesn't exist, skip config validation}
    "always_validate" : boolean = true
    "config_path" ? string
};

type ssh_client_type = {
    "options" ? ssh_client_options_type
    "comment_options" ? ssh_client_options_type
    "config_path" ? string
};

type component_ssh_type = {
    include structure_component
    "daemon" ? ssh_daemon_type
    "client" ? ssh_client_type
};

bind "/software/components/ssh" = component_ssh_type;
