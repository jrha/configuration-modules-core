# ${license-info}
# ${developer-info}
# ${author-info}


unique template components/authconfig/config-rpm;
include { 'components/authconfig/schema' };

# Package to install
"/software/packages" = pkg_repl("ncm-${project.artifactId}", "${no-snapshot-version}-${rpm.release}", "noarch");


"/software/components/authconfig/dependencies/pre" ?= list("spma");
"/software/components/authconfig/active" ?= true;
"/software/components/authconfig/dispatch" ?= true;

"/software/components/authconfig/safemode" ?= false;

"/software/components/authconfig/useshadow" ?= true;
"/software/components/authconfig/usecache" ?= true;

"/software/components/authconfig/usemd5" ?= true;
"/software/components/authconfig/passalgorithm" ?= {
    v = "md5";
    if (!value("/software/components/authconfig/usemd5")) {
	# Fall back to the most stupid option you can even imagin.
	# But it is portable. Huh.
	v = "descrypt";
    };
    v;
};
