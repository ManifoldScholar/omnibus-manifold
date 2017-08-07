if node[:platform] == "mac_os_x"
  svc_group = "wheel"
else
  svc_group = "root"
end

runit_service "logrotate" do
  down node['manifold']['logrotate']['ha']
  group svc_group
  control ['t']
  options({
    :log_directory => node['manifold']['logrotate']['log_directory']
  }.merge(params))
  log_options node['manifold']['logging'].to_hash.merge(node['manifold']['logrotate'].to_hash)
end

if node['manifold']['bootstrap']['enable']
  execute "/opt/manifold/bin/manifold-ctl start logrotate" do
    retries 20
  end
end
