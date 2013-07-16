version = node['graphite']['version']

python_pip 'whisper' do
    version node['graphite']['version']
    action :install
end

directory '/opt/graphite/storage/whisper/' do
  owner node['apache']['user']
  group node['apache']['group']
  recursive true
  notifies :restart, 'service[carbon-cache]'
end
