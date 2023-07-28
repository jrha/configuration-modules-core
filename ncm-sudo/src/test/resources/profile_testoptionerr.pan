# Simple testing profile for sudo component.
# One correct alias defined for users_aliases field and a wrong entry for
# command options. Should not compile.
object template profile_testoptionerr;

include pro_declaration_types;

include pro_declaration_component_sudo;
include pro_declaration_functions_sudo;

"/software/components/sudo/privilege_lines" = list (
	nlist ( "user",		"mejias",
		"run_as",	"munoz",
		"host",		"localhost",
		"cmd",		"/bin/ls",
		"options",	"INVALIDOPTION"
		)
	);

"/software/components/sudo/user_aliases" = nlist (
	"FOO", list ("bar")
	);
"/software/components/sudo/active" = true;
"/software/components/sudo/dispatch" = true;
