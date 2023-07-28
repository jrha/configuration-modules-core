object template ipv4_takeover;

include 'components/hostsfile/schema';

prefix '/software/components/hostsfile';

'active' = true;
'file' = '/tmp/hosts.local';
'takeover' = true;
'entries' = dict(
    'priv_1', dict(
        'ipaddr', '192.168.42.1',
        'comment', 'Private One',
    ),
    'priv_2', dict(
        'ipaddr', '192.168.42.2',
        'comment', 'Private Two',
    ),
    'priv_3', dict(
        'ipaddr', '192.168.42.3',
        'comment', 'Private Three',
    ),
);
