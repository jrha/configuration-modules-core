object template config;

include 'metaconfig/castor/config';

prefix "/software/components/metaconfig/services/{/etc/castor.conf}/contents";

'CLIENT/HIGHPORT' = 40000;
'CLIENT/LOWPORT' = 30000;
'CNS/CONRETRY' = 43200;
'CNS/CONRETRYINT' = 10;
'CNS/HOST' = 'catlasdlf.example.org';
'CSEC/DISABLE' = 'YES';
'DiskManager/ServerHosts' = list('atlaslsf.example.org', 'atlasdlf.example.org');
'RH/HOST' = 'catlasstager.example.org';
'RH/SRMHostsList' = list('srm04.example.org', 'srm05.example.org', 'srm06.example.org', 'srm13.example.org');
'STAGER/HOST' = 'atlasstager.example.org';
'STAGER/NOTIFYHOST' = 'atlasstager.example.org';
'STAGER/NOTIFYPORT' = 55015;
'TAPEGATEWAY/MAXWORKERTHREADS' = 20;
'TAPEGATEWAY/MINWORKERTHREADS' = 5;
'UPV/HOST' = 'castorns.example.org';
'VDQM/HOST' = 'nsd01.example.org';
'VMGR/HOST' = 'castorns.example.org';
