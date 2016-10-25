object template ssh_simple;

# mock pkg_repl
function pkg_repl = { null; };
include 'components/ssh/config';
# delete spma dependency (requires configured spma component otherwise)
"/software/components/ssh/dependencies" = null;

prefix "/software/components/ssh/daemon/options";

"AllowGroups" = "a b c";
"PidFile" = "/var/run";

"/software/components/ssh/daemon/options/MaxAuthTries" = 0;

prefix "/software/components/ssh/daemon/comment_options";

"Banner" = "Foobar";

prefix "/software/components/ssh/client/options";
"PreferredAuthentications" = list('gssapi-with-mic','hostbased','publickey');
"Port" = 22222;
"Compression" = 'delayed';
"MACs" = 'yes';
"GSSAPIAuthentication" = true;
"PasswordAuthentication" = 'no';
"RhostsRSAAuthentication" = false;
