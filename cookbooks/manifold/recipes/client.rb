account_helper = AccountHelper.new(node)

client_src = node['manifold']['client']['src']
client_listen_socket = node['manifold']['client']['socket']
client_socket_dir = File.dirname(client_listen_socket)
svc_group = node[:platform] == "mac_os_x" ? "wheel" : root
client_log_dir = node['manifold']['client']['log_directory']
user = account_helper.manifold_user
web_group = account_helper.web_server_group

directory client_socket_dir do
  owner user
  group web_group
  mode '0750'
  recursive true
end

[client_log_dir].each do |dir_name|
  directory dir_name do
    owner user
    mode '0700'
    recursive true
  end
end

runit_service "client" do
  down node['manifold']['client']['ha']
  group svc_group
  template_name 'client'
  control ['t']
  options({
              :service => "client",
              :user => user,
              :client_src => client_src,
              :log_directory => client_log_dir,
          })
  log_options node['manifold']['logging'].to_hash.merge(node['manifold']['client'].to_hash)
end

if node['manifold']['bootstrap']['enable']
  execute "/opt/manifold/bin/manifold-ctl start client" do
    retries 20
  end
end