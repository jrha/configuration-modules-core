object template dualstack;

prefix '/software/components/hostsfile';

'active' = true;
'file' = '/tmp/hosts.local';
'entries' = dict(
    'priv_1', dict(
        'ipaddr', '192.168.42.1',
        'comment', 'Private Four One',
    ),
    'priv_2', dict(
        'ipaddr', '192.168.42.2',
        'comment', 'Private Four Two',
    ),
    'priv_3', dict(
        'ipaddr', 'fd42:2a:2112:1::3',
        'comment', 'Private Six Three',
    ),
);
