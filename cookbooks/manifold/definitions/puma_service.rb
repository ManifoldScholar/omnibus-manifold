define :puma_service, :rails_app => nil, :user => nil do

  rails_app = params[:rails_app]
  rails_home = node['manifold'][rails_app]['dir']
  rails_src= node['manifold'][rails_app]['src']
  static_etc_dir = params[:static_etc_dir ]
  svc = params[:name]
  user = params[:user]
  svc_group = node[:platform] == "mac_os_x" ? "wheel" : "root"

  puma_dir = node['manifold'][svc]['dir']
  puma_rackup = node['manifold'][svc]['rackup']
  puma_pidfile = node['manifold'][svc]['pidfile']
  puma_statefile = node['manifold'][svc]['statefile']
  puma_log_dir = node['manifold'][svc]['log_directory']
  puma_listen_socket = node['manifold'][svc]['socket']
  puma_listen_address = node['manifold'][svc]['listen']
  puma_worker_count = node['manifold'][svc]['worker_count']
  puma_socket_dir = File.dirname(puma_listen_socket)
  puma_application = svc == "cable" ? "cable" : "api"

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

  runit_service svc do
    down node['manifold'][svc]['ha']
    group svc_group
    template_name 'puma'
    control ['t']
    options({
      :service => svc,
      :rails_home => rails_home,
      :env_prefix => puma_application == "cable" ? "API_CABLE" : "API",
      :puma_dir => puma_dir,
      :puma_rackup => puma_rackup,
      :puma_pidfile => puma_pidfile,
      :puma_statefile => puma_statefile,
      :puma_listen_socket => puma_listen_socket,
      :puma_listen_address => puma_listen_address,
      :puma_worker_count => puma_worker_count,
      :static_etc_dir => static_etc_dir,
      :user => user,
      :source => rails_src,
      :rails_app => rails_app,
      :log_directory => puma_log_dir
    }.merge(params))
    log_options node['manifold']['logging'].to_hash.merge(node['manifold'][svc].to_hash)
  end

  if node['manifold']['bootstrap']['enable']
    execute "/opt/manifold/bin/manifold-ctl start #{svc}" do
      retries 20
    end
  end
end
