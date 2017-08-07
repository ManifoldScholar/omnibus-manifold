logrotate_dir = node['manifold']['logrotate']['dir']
logrotate_log_dir = node['manifold']['logrotate']['log_directory']
logrotate_d_dir = File.join(logrotate_dir, 'logrotate.d')

[
    logrotate_dir,
    logrotate_d_dir,
    logrotate_log_dir
].each do |dir|
  directory dir do
    mode "0700"
  end
end

template File.join(logrotate_dir, "logrotate.conf") do
  mode "0644"
  variables(node['manifold']['logrotate'].to_hash)
end

node['manifold']['logrotate']['services'].each do |svc|
  template File.join(logrotate_d_dir, svc) do
    source 'logrotate-service.erb'
    variables(
        log_directory: node['manifold'][svc]['log_directory'],
        options: node['manifold']['logging'].to_hash.merge(node['manifold'][svc].to_hash)
    )
  end
end

# Configure Services
# TODO: Add Puma
[
    "sidekiq",
#    "nginx",
#    "remote-syslog",
#    "logrotate",
#    "bootstrap",
].each do |service|
  if node["manifold"][service]["enable"]
    include_recipe "manifold::#{service}"
  else
    include_recipe "manifold::#{service}_disable"
  end
end
