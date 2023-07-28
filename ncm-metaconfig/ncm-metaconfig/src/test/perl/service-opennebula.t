use Test::Quattor::ProfileCache qw(set_json_typed get_json_typed);
BEGIN {
    set_json_typed()
}

use Test::More;
use Test::Quattor::TextRender::Metaconfig;

my $u = Test::Quattor::TextRender::Metaconfig->new(
    service => 'opennebula',
    usett => 0,
)->test();

done_testing;
