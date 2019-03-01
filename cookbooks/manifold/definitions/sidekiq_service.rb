define :sidekiq_service, :rails_app => nil, :user => nil do
  svc = params[:name]
  user = params[:user]
  rails_app = params[:rails_app]
  src_dir = params[:src_dir]
  if node[:platform] == "mac_os_x"
    svc_group = "wheel"
  else
    svc_group = "root"
  end
  rails_src = node['manifold'][rails_app]['src']
  sidekiq_log_dir = node['manifold'][svc]['log_directory']

  directory sidekiq_log_dir do
    owner user
    mode '0700'
    recursive true
  end

  runit_service svc do
    down node['manifold'][svc]['ha']
    template_name 'sidekiq'
    group svc_group
    options({
      :rails_app => rails_app,
      :src_dir => src_dir,
      :rails_src => rails_src,
      :user => user,
      :shutdown_timeout => node['manifold'][svc]['shutdown_timeout'],
      :concurrency => node['manifold'][svc]['concurrency'],
      :log_directory => sidekiq_log_dir
    }.merge(params))
    log_options node['manifold']['logging'].to_hash.merge(node['manifold'][svc].to_hash)
  end

  if node['manifold']['bootstrap']['enable']
    execute "/opt/manifold/bin/manifold-ctl start #{svc}" do
      retries 20
    end
  end
end
