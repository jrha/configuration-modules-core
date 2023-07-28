# ${license-info}
# ${developer-info}
# ${author-info}


unique template components/ccm/config-rpm;
include {'components/ccm/schema'};

# Package to install
"/software/packages" = pkg_repl("ncm-${project.artifactId}", "${no-snapshot-version}-${rpm.release}", "noarch");

'/software/components/ccm/dependencies/pre' ?= list('spma');

'/software/components/ccm/version' ?= '${no-snapshot-version}';

