include_recipe 'cron'

package 'python-twisted'

cache_instances = []
node['graphite']['carbon']['caches'].keys.sort.map {|c| cache_instances.push(c)}
relay_instances = []
node['graphite']['relay']['relays'].keys.sort.map {|r| relay_instances.push(r)}

if Chef::Config[:solo]
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
else
  query = "role:graphite-server AND chef_environment:#{node.chef_environment}"
  graphite_hosts = search(:node, query).map {|n| n.ipaddress}
  graphite_hosts = [ node.ipaddress ] if graphite_hosts.empty?
  graphite_hosts_relayport = []
  cache_instances.each do |cache|
    graphite_hosts.each do |ip|
      graphite_hosts_relayport.push(
        "#{ip}:#{node['graphite']['carbon']['caches'][cache]['pickle_receiver_port']}:#{cache}")
    end
  end
  Chef::Log.info("Found graphite server hosts: #{graphite_hosts.join(', ')}")
end

cache_instances.each do |cache|
  AFW.create_rule(
    node,
    'Graphite carbon-cache pickle listener',
    {
      'protocol' => 'tcp',
      'direction' => 'in',
      'user' => 'www-data',
      'source' => 'roles:graphite-server',
      'dport' => node['graphite']['carbon']['caches'][cache]['pickle_receiver_port']
    }
  )
  AFW.create_rule(
    node,
    'Graphite carbon-cache listener',
    {
      'protocol' => 'tcp',
      'direction' => 'in',
      'user' => 'www-data',
      'source' => 'roles:graphite-server',
      'dport' => node['graphite']['carbon']['caches'][cache]['line_receiver_port']
    }
  )
end

python_pip 'carbon' do
    version node['graphite']['version']
    action :install
end

template '/opt/graphite/conf/carbon.conf' do
  owner node['apache']['user']
  group node['apache']['group']
  variables(
    :caches => node['graphite']['carbon']['caches'],
    :relays => node['graphite']['relay']['relays'],
    :graphite_hosts => graphite_hosts_relayport.join(', ')
  )
end

directories = ['/opt/graphite/lib/twisted/plugins',
               '/opt/graphite/storage',
               '/opt/graphite/storage/log'
              ]

directories.each do |dir|
  directory dir do
    owner node['apache']['user']
    group node['apache']['group']
  end
end

template '/opt/graphite/conf/storage-schemas.conf' do
  owner node['apache']['user']
  group node['apache']['group']
  variables( :schemas => node['graphite']['schemas'] )
end

template '/opt/graphite/conf/relay-rules.conf' do
  owner node['apache']['user']
  group node['apache']['group']
  variables( :routes => node['graphite']['routes'],
             :graphite_hosts => graphite_hosts_relayport.join(', ')
           )
  notifies :restart, 'service[carbon-relay]', :delayed
end

template '/etc/init.d/carbon-cache' do
  source 'carbon-initd.erb'
  variables( :init_name => 'carbon-cache' )
  owner 'root'
  group 'root'
  mode '0755'
end

template '/etc/init.d/carbon-relay' do
  source 'carbon-initd.erb'
  variables( :init_name => 'carbon-relay' )
  owner 'root'
  group 'root'
  mode '0755'
end

template '/etc/default/carbon-daemons' do
  source 'carbon-daemons.erb'
  variables(
    :cache_instances => cache_instances.join(' '),
    :relay_instances => relay_instances.join(' ')
  )
  owner 'root'
  group 'root'
end

['/etc/init/carbon-cache.conf', '/etc/init/carbon-relay.conf'].each do |init|
  file init do
    action :delete
  end
end

service 'carbon-cache' do
  provider Chef::Provider::Service::Init
  supports :status => true, :restart => true
  action [ :start ]
  subscribes :restart, resources('template[/opt/graphite/conf/carbon.conf]'), :delayed
  subscribes :restart, resources('template[/opt/graphite/conf/storage-schemas.conf]'), :delayed
  subscribes :restart, resources('template[/etc/init.d/carbon-cache]'), :delayed
  subscribes :restart, resources('template[/etc/default/carbon-daemons]'), :delayed
  notifies :restart, 'service[carbon-relay]', :delayed
  only_if { node['graphite']['carbon']['cache']['enabled'] }
end

service 'carbon-relay' do
  provider Chef::Provider::Service::Init
  supports :status => true, :restart => false
  action [ :start ]
  subscribes :restart, resources('template[/etc/init.d/carbon-relay]'), :delayed
  subscribes :restart, resources('template[/etc/default/carbon-daemons]'), :delayed
  only_if { File.exists?('/opt/graphite/conf/relay-rules.conf') and
    node['graphite']['carbon']['relay']['enabled'] }
end

logrotate_app 'carbon-logs' do
  cookbook 'logrotate'
  path '/opt/graphite/storage/log/carbon-cache-*/*.log'
  frequency node['graphite']['carbon']['log_rotate_freq']
  rotate node['graphite']['carbon']['keep_num_logs']
  create '644 www-data www-data'
end

logrotate_app 'carbon-relay-logs' do
  cookbook 'logrotate'
  path '/opt/graphite/storage/log/carbon-relay-*/*.log'
  frequency node['graphite']['relay']['log_rotate_freq']
  rotate node['graphite']['relay']['keep_num_logs']
  create '644 www-data www-data'
  only_if 'test -e /opt/graphite/conf/relay-rules.conf'
end

cron 'graphite-carbon' do
  command '/usr/bin/find /opt/graphite/storage/log/*/ -regex ".*\.[0-9][0-9][0-9][0-9]_.*" -delete'
  minute '0'
  hour '1'
end
