define :puma_service, :rails_app => nil, :user => nil do

  config_template = params[:config_template]
  rails_app = params[:rails_app]
  static_etc_dir = params[:static_etc_dir ]
  rails_home = node['manifold'][rails_app]['dir']
  rails_src= node['manifold'][rails_app]['src']
  svc = params[:name]
  user = params[:user]
  svc_group = node[:platform] == "mac_os_x" ? "wheel" : "root"
  puma_dir = node['manifold'][svc]['dir']
  puma_rackup = node['manifold'][svc]['rackup']
  puma_etc_dir = File.join(rails_home, "etc")
  puma_pidfile = node['manifold'][svc]['pidfile']
  puma_log_dir = node['manifold'][svc]['log_directory']
  puma_listen_socket = node['manifold'][svc]['socket']
  puma_socket_dir = File.dirname(puma_listen_socket)
  puma_rb = File.join(puma_etc_dir, "#{svc}/#{svc}.rb")

  [
    puma_log_dir,
    puma_dir
  ].each do |dir_name|
    directory dir_name do
      owner user
      mode '0700'
      recursive true
    end
  end

  directory puma_socket_dir do
    owner user
    group AccountHelper.new(node).web_server_group
    mode '0750'
    recursive true
  end

  puma_config puma_rb do
    dir puma_dir
    config_template config_template
    socket puma_listen_socket
    pid puma_pidfile
  end

  runit_service svc do
    down node['manifold'][svc]['ha']
    group svc_group
    template_name 'puma'
    control ['t']
    options({
      :service => svc,
      :rails_home => rails_home,
      :static_etc_dir => static_etc_dir,
      :user => user,
      :config => puma_rb,
      :source => rails_src,
      :rails_app => rails_app,
      :log_directory => puma_log_dir,
      :rackup => puma_rackup
    }.merge(params))
    log_options node['manifold']['logging'].to_hash.merge(node['manifold'][svc].to_hash)
  end

  if node['manifold']['bootstrap']['enable']
    execute "/opt/manifold/bin/manifold-ctl start #{svc}" do
      retries 20
    end
  end
end
