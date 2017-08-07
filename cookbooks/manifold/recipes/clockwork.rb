account_helper = AccountHelper.new(node)

if node[:platform] == "mac_os_x"
  svc_group = "wheel"
else
  svc_group = "root"
end

svc = params[:name]
user = account_helper.manifold_user
clockwork_log_dir = node['manifold']['clockwork']['log_directory']
rails_app = "manifold-api"
rails_home = node['manifold'][rails_app]['dir']
rails_src = node['manifold'][rails_app]['src']
static_etc_dir = "/opt/manifold/etc/manifold/api"

[clockwork_log_dir].each do |dir_name|
  directory dir_name do
    owner user
    mode '0700'
    recursive true
  end
end

runit_service "clockwork" do
  group svc_group
  restart_command 2 # Restart Clockwork using SIGUSR2
  template_name 'clockwork'
  control ['t']
  options({
              :static_etc_dir => static_etc_dir,
              :log_directory => clockwork_log_dir,
              :service => svc,
              :rails_home => rails_home,
              :rails_src => rails_src,
              :user => user
          }.merge(params))
  log_options node['manifold']['logging'].to_hash.merge(node['manifold']['logrotate'].to_hash)
end

if node['manifold']['bootstrap']['enable']
  execute "/opt/manifold/bin/manifold-ctl start clockwork" do
    retries 20
  end
end
