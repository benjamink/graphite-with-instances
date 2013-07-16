include_recipe 'apache2::mod_python'

version = node['graphite']['version']

package 'python-cairo-dev'
package 'python-django'
package 'python-django-tagging'
package 'python-memcache'
package 'python-rrdtool'

python_pip 'graphite-web' do
    version node['graphite']['version']
    action :install
end

template '/etc/apache2/sites-available/graphite' do
  source 'graphite-vhost.conf.erb'
end

apache_site '000-default' do
  enable false
end

apache_site 'graphite'

directory '/opt/graphite/storage/log/webapp' do
  owner node['apache']['user']
  group node['apache']['group']
end

cookbook_file '/opt/graphite/bin/set_admin_passwd.py' do
  mode '755'
end

cookbook_file '/opt/graphite/storage/graphite.db' do
  action :create_if_missing
  notifies :run, 'execute[set admin password]'
end

execute 'set admin password' do
  command "/opt/graphite/bin/set_admin_passwd.py root #{node['graphite']['password']}"
  action :nothing
end

file '/opt/graphite/storage/graphite.db' do
  owner node['apache']['user']
  group node['apache']['group']
  mode '644'
end

template '/opt/graphite/webapp/graphite/local_settings.py' do
  owner node['apache']['user']
  group node['apache']['group']
  mode '644'
  notifies :reload, 'service[apache2]', :delayed
end
