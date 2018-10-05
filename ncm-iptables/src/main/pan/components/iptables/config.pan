# ${license-info}
# ${developer-info}
# ${author-info}
# ${build-info}

unique template components/${project.artifactId}/config;

include "components/${project.artifactId}/schema";

# Package to install.
"/software/packages" = pkg_repl("ncm-${project.artifactId}", "${no-snapshot-version}-${rpm.release}", "noarch");

prefix '/software/components/${project.artifactId}';

'active' ?= true;
'dispatch' ?= true;
'dependencies/pre' = append("spma");


variable XROOTD_MONIT_CONFIG ?= <<EOF;
set mailserver csf-mail.rl.ac.uk
set alert andrew.lahiff@stfc.ac.uk but not on { nonexist, instance }

check process xrootd with pidfile /tmp/xrootd.pid
      start program = "/etc/init.d/xrootd start"
      stop  program = "/etc/init.d/xrootd stop"

check process cmsd with pidfile /tmp/cmsd.pid
      start program = "/etc/init.d/cmsd start"
      stop  program = "/etc/init.d/cmsd stop"
EOF

'/software/components/filecopy/services/{/etc/monit.d/xrootd.conf}' = dict(
    'config', XROOTD_MONIT_CONFIG,
    'backup', false,
    'owner', 'root:root',
    'restart', '/usr/sbin/monit reload',
    'perms', '0644',
);
