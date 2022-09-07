declaration template metaconfig/telegraf/schema;

include 'pan/types';

type telegraf_agent =  {
};

type telegraf_global_tags = {
};

type telegraf_input = {
};

type telegraf_output = {
};

type service_telegraf = {
    'agent' ? telegraf_agent
    'global_tags' ? telegraf_global_tags
    'inputs' ? telegraf_input{}
    'outputs' ? telegraf_output{}
};
