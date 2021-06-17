account_helper = AccountHelper.new(node)
omnibus_helper = OmnibusHelper.new(node)

svc = params[:name]
elasticsearch_dir = node['manifold']['elasticsearch']['dir']
elasticsearch_data_dir = node['manifold']['elasticsearch']['data_dir_v7']
elasticsearch_log_dir = node['manifold']['elasticsearch']['log_directory']
elasticsearch_user = account_helper.elasticsearch_user
elasticsearch_group = account_helper.elasticsearch_group
elasticsearch_plugin_dir= "#{node['package']['install-dir']}/embedded/elasticsearch/plugins"
elasticsearch_config_dir= "#{node['package']['install-dir']}/embedded/elasticsearch/config"

if node[:platform] == "mac_os_x"
  svc_group = "wheel"
else
  svc_group = "root"
end

account "Elasticsearch user and group" do
  username elasticsearch_user
  uid node['manifold']['elasticsearch']['uid']
  ugid elasticsearch_user
  groupname elasticsearch_group
  gid node['manifold']['elasticsearch']['gid']
  shell node['manifold']['elasticsearch']['shell']
  home node['manifold']['elasticsearch']['home']
  manage node['manifold']['manage-accounts']['enable']
end

directory elasticsearch_plugin_dir do
  owner elasticsearch_user
  mode "0755"
  recursive true
end

directory elasticsearch_config_dir do
  owner elasticsearch_user
  mode "0755"
  recursive true
end

directory elasticsearch_dir do
  owner elasticsearch_user
  mode "0755"
  recursive true
end

[
    elasticsearch_data_dir,
    elasticsearch_log_dir
].each do |dir|
  directory dir do
    owner elasticsearch_user
    mode "0700"
    recursive true
  end
end

elasticsearch_config = File.join(elasticsearch_dir, "elasticsearch.yml")
elasticsearch_log_config = File.join(elasticsearch_dir, "log4j2.properties")
elasticsearch_jvm_options = File.join(elasticsearch_dir, "jvm.options")
should_notify = omnibus_helper.should_notify?("elasticsearch")

template elasticsearch_jvm_options do
  source "elasticsearch-jvm.options.erb"
  owner elasticsearch_user
  mode "0644"
  variables(node['manifold']['elasticsearch'].to_hash)
  notifies :restart, 'service[elasticsearch]', :delayed if should_notify
end

template elasticsearch_config do
  source "elasticsearch.conf.erb"
  owner elasticsearch_user
  mode "0644"
  variables(node['manifold']['elasticsearch'].to_hash)
  notifies :restart, 'service[elasticsearch]', :delayed if should_notify
end

template elasticsearch_log_config do
  source "elasticsearch-log4j2.properties.erb"
  owner elasticsearch_user
  mode "0644"
  variables(node['manifold']['elasticsearch'].to_hash)
  notifies :restart, 'service[elasticsearch]', :delayed if should_notify
end

runit_service "elasticsearch" do
  down node['manifold']['elasticsearch']['ha']
  group svc_group
  control(['t'])
  options({
              :log_directory => elasticsearch_log_dir,
              :elasticsearch_data_dir => elasticsearch_data_dir,
              :elasticsearch_user => elasticsearch_user,
              :elasticsearch_dir => elasticsearch_dir,
              :service => svc,
          }.merge(params))
  log_options node['manifold']['logging'].to_hash.merge(node['manifold']['elasticsearch'].to_hash)
end