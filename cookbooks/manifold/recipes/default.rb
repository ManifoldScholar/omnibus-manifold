#
# Cookbook:: manifold
# Recipe:: default
#
# Copyright:: 2017, Zach Davis, All Rights Reserved.
install_dir = node['package']['install-dir']

root_user = "root"
if node[:platform] == "mac_os_x"
  root_group = "wheel"
else
  root_group = "root"
end

ENV['PATH'] = "#{install_dir}/bin:#{install_dir}/embedded/bin:#{ENV['PATH']}"

include_recipe 'manifold::config'

directory "/etc/manifold" do
  owner root_user
  group root_group
  mode "0775"
  only_if { node['manifold']['manage-storage-directories']['manage_etc'] }
end.run_action(:create)

if File.exists?("/var/opt/manifold/bootstrapped")
	node.default['manifold']['bootstrap']['enable'] = false
end

directory "Create /var/opt/manifold/etc" do
  path "/var/opt/manifold/etc"
  owner root_user
  group root_group
  mode "0755"
  recursive true
  action :create
end

directory "#{install_dir}/embedded/etc" do
  owner root_user
  group root_group
  mode "0755"
  recursive true
  action :create
end

# This recipe needs to run before manifold-api
# because we add `manifold-www` user to some groups created by that recipe
include_recipe "manifold::web-server"

if node['manifold']['manifold-api']['enable']
  include_recipe "manifold::users"
  include_recipe "manifold::manifold-api"
end

# Add trusted certs recipe
include_recipe "manifold::add_trusted_certs"

# Create dummy puma and sidekiq services to receive notifications, in case
# the corresponding service recipe is not loaded below.
[
    "puma",
    "sidekiq"
].each do |dummy|
  service "create a temporary #{dummy} service" do
    service_name dummy
    supports []
  end
end

# Install our runit instance
include_recipe "runit"

# Configure Storage Services
[
    "redis",
    "postgresql" # Postgresql depends on Redis because of `rake db:seed_fu`
].each do |service|
  if node["manifold"][service]["enable"]
    include_recipe "manifold::#{service}"
  else
    include_recipe "manifold::#{service}_disable"
  end
end

# Always create logrotate folders and configs, even if the service is not enabled.
include_recipe "manifold::logrotate_config"

# Setup the api env file
manifold_source_dir = "/opt/manifold/embedded/src"

# TODO: Handle HTTPS?
port = node['manifold']['nginx']['listen_port']
domain = node['manifold']['manifold-api']['manifold_host'] || "127.0.0.1"
api_url_parts = ["http://"]
api_url_parts << domain
api_url_parts << ":#{port}" if port && port != 80

cable_url_parts = ["ws://"]
cable_url_parts << domain
cable_url_parts << ":#{port}" if port && port != 80
cable_url_parts << "/cable"

port = node['manifold']['elasticsearch']['port']
bind = node['manifold']['elasticsearch']['bind']
elasticsearch_url_parts = ["http://"]
elasticsearch_url_parts << bind
elasticsearch_url_parts << ":#{port}" if port

vars = {
    fqdn: node['manifold']['manifold-api']['manifold_host'] || "127.0.0.1",
    api: node['manifold']['manifold-api'].to_hash,
    nginx: node['manifold']['nginx'].to_hash,
    client: node['manifold']['client'].to_hash,
    domain: domain,
    api_url: api_url_parts.join(""),
    cable_url: cable_url_parts.join(""),
    elasticsearch_url: elasticsearch_url_parts.join(""),
    additional_env: node['manifold']['manifold-api']['env']
}

templatesymlink "Setup the API app environment" do
  link_from File.join(manifold_source_dir, ".env")
  link_to File.join("/var/opt/manifold/etc", "api-env.sh")
  source "api-env.erb"
  owner root_user
  group root_group
  mode "0644"
  variables(vars)
end

templatesymlink "Setup the client node app environment" do
  link_from File.join(manifold_source_dir, "client/dist/manifold/ssr", "ssr.config.js")
  link_to File.join("/var/opt/manifold/etc", "node-env.js")
  source "node-env.js.erb"
  owner root_user
  group root_group
  mode "0644"
  variables(vars)
end

templatesymlink "Setup the client browser environment" do
  link_from File.join(manifold_source_dir, "client/dist/manifold/www", "browser.config.js")
  link_to File.join("/var/opt/manifold/etc", "browser-env.js")
  source "browser-env.js.erb"
  owner root_user
  group root_group
  mode "0644"
  variables(vars)
end

# Configure Services
[
    "elasticsearch",
    "nginx",
    "logrotate",
    "bootstrap",
    "client",
    "sidekiq",
    "clockwork",
    "puma",
    "cable"
].each do |service|
  if node["manifold"][service]["enable"]
    include_recipe "manifold::#{service}"
  else
    include_recipe "manifold::#{service}_disable"
  end
end

include_recipe "manifold::database_migrations"
