# ${license-info}
# ${developer-info}
# ${author-info}


unique template components/xen/config-rpm;

include { "components/xen/schema" };

# Package to install.
"/software/packages" = pkg_repl("ncm-${project.artifactId}", "${no-snapshot-version}-${rpm.release}", "noarch");


# standard component settings
"/software/components/xen/dependencies/pre" = list("spma");
"/software/components/xen/active" ?=  true ;
"/software/components/xen/dispatch" ?=  true ;
"/software/components/xen/register_change/0" = "/software/components/xen";



