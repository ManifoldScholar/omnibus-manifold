account_helper = AccountHelper.new(node)
omnibus_helper = OmnibusHelper.new(node)

nginx_dir       = node['manifold']['nginx']['dir']
nginx_conf_dir  = File.join(nginx_dir, "conf")
nginx_log_dir   = node['manifold']['nginx']['log_directory']

if node[:platform] == "mac_os_x"
  svc_group = "wheel"
else
  svc_group = "root"
end

# These directories do not need to be writable for manifold-www
[
  nginx_dir,
  nginx_conf_dir,
  nginx_log_dir,
].each do |dir_name|
  directory dir_name do
    owner 'root'
    group account_helper.web_server_group
    mode '0750'
    recursive true
  end
end

link File.join(nginx_dir, "logs") do
  to nginx_log_dir
end

nginx_config          = File.join(nginx_conf_dir, "nginx.conf")
manifold_api_http_conf = File.join(nginx_conf_dir, "manifold-http.conf")
nginx_status_conf     = File.join(nginx_conf_dir, "nginx-status.conf")

# If the service is enabled, check if we are using internal nginx
manifold_api_enabled = if node['manifold']['manifold-api']['enable']
                         node['manifold']['nginx']['enable']
                       else
                         false
                       end

nginx_status_enabled = node['manifold']['nginx']['status']['enable']

# Include the config file for manifold-api in nginx.conf later
nginx_vars = node['manifold']['nginx'].to_hash.merge({
  manifold_http_config:    manifold_api_enabled   ? manifold_api_http_conf : nil,
  nginx_status_config:  nginx_status_enabled  ? nginx_status_conf     : nil,
})

if nginx_vars['listen_https'].nil?
  nginx_vars['https'] = node['manifold']['manifold-api']['manifold_https']
else
  nginx_vars['https'] = nginx_vars['listen_https']
end

template manifold_api_http_conf do
  source "nginx-manifold-http.conf.erb"
  owner "root"
  group svc_group
  mode "0644"
  variables(nginx_vars.merge(
    {
      :fqdn => node['manifold']['manifold-api']['manifold_host'] || "127.0.0.1",
      :relative_url => node['manifold']['manifold-api']['manifold_relative_url'],
    }
  ))
  notifies :restart, 'service[nginx]' if omnibus_helper.should_notify?("nginx")

  action manifold_api_enabled ? :create : :delete
end

template nginx_status_conf do
  source "nginx-status.conf.erb"
  owner "root"
  group svc_group
  mode "0644"
  variables ({
    :listen_addresses => nginx_vars['status']['listen_addresses'],
    :fqdn => nginx_vars['status']['fqdn'],
    :port => nginx_vars['status']['port'],
    :options => nginx_vars['status']['options']
  })

  notifies :restart, 'service[nginx]' if omnibus_helper.should_notify?("nginx")

  action nginx_status_enabled ? :create : :delete
end

nginx_vars['manifold_access_log_format'] = node['manifold']['nginx']['log_format']

template nginx_config do
  source "nginx.conf.erb"
  owner "root"
  group svc_group
  mode "0644"
  variables nginx_vars
  notifies :restart, 'service[nginx]' if omnibus_helper.should_notify?("nginx")
end

if nginx_vars.key?('custom_error_pages')
  nginx_vars['custom_error_pages'].each_key do |code|
    template "#{ManifoldApi.public_path}/#{code}-custom.html" do
      source "manifold-api-error.html.erb"
      owner "root"
      group svc_group
      mode "0644"

      variables(
        :code     => code,
        :title    => nginx_vars['custom_error_pages'][code]['title'],
        :header   => nginx_vars['custom_error_pages'][code]['header'],
        :message  => nginx_vars['custom_error_pages'][code]['message']
      )

      notifies :restart, 'service[nginx]' if omnibus_helper.should_notify?("nginx")
    end
  end
end

runit_service "nginx" do
  down node['manifold']['nginx']['ha']
  group svc_group
  options({
    :log_directory => nginx_log_dir
  }.merge(params))
  log_options node['manifold']['logging'].to_hash.merge(node['manifold']['nginx'].to_hash)
end

if node['manifold']['bootstrap']['enable']
  execute "/opt/manifold/bin/manifold-ctl start nginx" do
    retries 20
  end
end
