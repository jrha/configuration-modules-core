# ${license-info}
# ${developer-info}
# ${author-info}

unique template components/spma/yum/config;

# Prefix for packages
prefix '/software';

# Package to install
'packages' = pkg_repl("ncm-${project.artifactId}", "${no-snapshot-version}-${rpm.release}", "noarch");

# Set prefix to root of component configuration.
prefix '/software/components/${project.artifactId}';

'packager' = 'yum';

'register_change' ?= list(
    "/software/packages",
    "/software/repositories",
);
