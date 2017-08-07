define :redis_service, :socket_group => nil do
  svc = params[:name]
  if node[:platform] == "mac_os_x"
    svc_group = "wheel"
  else
    svc_group = "root"
  end

  redis_dir = node['manifold'][svc]['dir']
  redis_log_dir = node['manifold'][svc]['log_directory']
  redis_user = AccountHelper.new(node).redis_user
  omnibus_helper = OmnibusHelper.new(node)

  account 'user and group for redis' do
    username redis_user
    uid node['manifold'][svc]['uid']
    ugid redis_user
    groupname redis_user
    gid node['manifold'][svc]['gid']
    shell  node['manifold'][svc]['shell']
    home node['manifold'][svc]['home']
    manage node['manifold']['manage-accounts']['enable']
  end

  group 'Socket group' do
    append true # we need this so we don't remove members
    group_name params[:socket_group]
  end

  directory redis_dir do
    owner redis_user
    group params[:socket_group]
    mode "0750"
  end

  directory redis_log_dir do
    owner redis_user
    mode "0700"
  end

  redis_config = File.join(redis_dir, "redis.conf")
  is_slave = node['manifold'][svc]['master_ip'] &&
      node['manifold'][svc]['master_port'] &&
      !node['manifold'][svc]['master']

  template redis_config do
    source "redis.conf.erb"
    owner redis_user
    mode "0644"
    variables(node['manifold'][svc].to_hash.merge({is_slave: is_slave}))
    notifies :restart, "service[#{svc}]", :immediately if omnibus_helper.should_notify?(svc)
  end

  runit_service svc do
    down node['manifold'][svc]['ha']
    template_name 'redis'
    group svc_group
    options({
                :service => svc,
                :log_directory => redis_log_dir
            }.merge(params))
    log_options node['manifold']['logging'].to_hash.merge(node['manifold'][svc].to_hash)
  end

  if node['manifold']['bootstrap']['enable']
    execute "/opt/manifold/bin/manifold-ctl start #{svc}" do
      retries 20
    end
  end
end
