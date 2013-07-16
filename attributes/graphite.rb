default['graphite']['version'] = '0.9.10'
default['graphite']['pid_dir'] = '/var/run'
default['graphite']['graphite_root'] = '/opt/graphite'

default['graphite']['carbon']['cache']['enabled'] = true
default['graphite']['carbon']['relay']['enabled'] = true

default['graphite']['carbon']['data_dir'] = '/opt/graphite/storage/whisper/'
default['graphite']['carbon']['user'] = 'www-data'
default['graphite']['carbon']['max_cache_size'] = 'inf'
default['graphite']['carbon']['max_updates_per_second'] = '7500'
default['graphite']['carbon']['max_creates_per_minute'] = '50'
default['graphite']['carbon']['log_updates'] = 'False'
default['graphite']['carbon']['keep_num_logs'] = '7'
default['graphite']['carbon']['log_rotate_freq'] = 'daily'
default['graphite']['relay']['keep_num_logs'] = '7'
default['graphite']['relay']['log_rotate_freq'] = 'daily'

default['graphite']['password'] = 'change_me'

default['graphite']['webapp']['timezone'] = 'America/New_York'

default['graphite']['schemas'] = []
default['graphite']['catchall']['priority'] = '0'
default['graphite']['catchall']['pattern'] = '^.*'
default['graphite']['catchall']['retentions'] = '30:2880'

default['graphite']['routes'] = []

default['graphite']['carbon']['caches']['a'] = {
  'line_receiver_interface' => '0.0.0.0',
  'line_receiver_port' => '2031',
  'pickle_receiver_interface' => '0.0.0.0',
  'pickle_receiver_port' => '2041',
  'cache_query_interface' => '0.0.0.0',
  'cache_query_port' => '7021'
}

default['graphite']['relay']['relays']['a'] = {
  'relay_method' => 'consistent-hashing',
  'replication_factor' => '2',
  'line_receiver_interface' => '0.0.0.0',
  'line_receiver_port' => '2003',
  'pickle_receiver_interface' => '0.0.0.0',
  'pickle_receiver_port' => '2004',
  'max_queue_size' => '1000',
  'destinations' => 'graphite_hosts'
}


