account_helper = AccountHelper.new(node)
omnibus_helper = OmnibusHelper.new(node)

postgresql_dir = node['manifold']['postgresql']['dir']
postgresql_data_dir = node['manifold']['postgresql']['data_dir']
postgresql_data_dir_symlink = File.join(postgresql_dir, "data")
postgresql_log_dir = node['manifold']['postgresql']['log_directory']
postgresql_socket_dir = node['manifold']['postgresql']['unix_socket_directory']
postgresql_user = account_helper.postgresql_user

if node[:platform] == "mac_os_x"
  svc_group = "wheel"
else
  svc_group = "root"
end

pg_helper = PgHelper.new(node)

account "Postgresql user and group" do
  username postgresql_user
  uid node['manifold']['postgresql']['uid']
  ugid postgresql_user
  groupname postgresql_user
  gid node['manifold']['postgresql']['gid']
  shell node['manifold']['postgresql']['shell']
  home node['manifold']['postgresql']['home']
  manage node['manifold']['manage-accounts']['enable']
end

directory postgresql_dir do
  owner postgresql_user
  mode "0755"
  recursive true
end

[
  postgresql_data_dir,
  postgresql_log_dir
].each do |dir|
  directory dir do
    owner postgresql_user
    mode "0700"
    recursive true
  end
end

link postgresql_data_dir_symlink do
  to postgresql_data_dir
  not_if { postgresql_data_dir == postgresql_data_dir_symlink }
end

file File.join(node['manifold']['postgresql']['home'], ".profile") do
  owner postgresql_user
  mode "0600"
  content <<-EOH
PATH=#{node['manifold']['postgresql']['user_path']}
EOH
end

sysctl "kernel.shmmax" do
  value node['manifold']['postgresql']['shmmax']
end

sysctl "kernel.shmall" do
  value node['manifold']['postgresql']['shmall']
end

sem = "#{node['manifold']['postgresql']['semmsl']} "
sem += "#{node['manifold']['postgresql']['semmns']} "
sem += "#{node['manifold']['postgresql']['semopm']} "
sem += "#{node['manifold']['postgresql']['semmni']}"
sysctl "kernel.sem" do
  value sem
end

execute "/opt/manifold/embedded/bin/initdb -D #{postgresql_data_dir} -E UTF8" do
  user postgresql_user
  not_if { File.exists?(File.join(postgresql_data_dir, "PG_VERSION")) }
end

postgresql_config = File.join(postgresql_data_dir, "postgresql.conf")
should_notify = omnibus_helper.should_notify?("postgresql")

template postgresql_config do
  source "postgresql.conf.erb"
  owner postgresql_user
  mode "0644"
  helper(:pg_helper) { pg_helper }
  variables(node['manifold']['postgresql'].to_hash)
  notifies :restart, 'service[postgresql]', :immediately if should_notify
end

pg_hba_config = File.join(postgresql_data_dir, "pg_hba.conf")

template pg_hba_config do
  source "pg_hba.conf.erb"
  owner postgresql_user
  mode "0644"
  variables(node['manifold']['postgresql'].to_hash)
  notifies :restart, 'service[postgresql]', :immediately if should_notify
end

template File.join(postgresql_data_dir, "pg_ident.conf") do
  owner postgresql_user
  mode "0644"
  variables(node['manifold']['postgresql'].to_hash)
  notifies :restart, 'service[postgresql]', :immediately  if should_notify
end

runit_service "postgresql" do
  down node['manifold']['postgresql']['ha']
  group svc_group
  control(['t'])
  options({
    :log_directory => postgresql_log_dir
  }.merge(params))
  log_options node['manifold']['logging'].to_hash.merge(node['manifold']['postgresql'].to_hash)
end

# This recipe must be ran BEFORE any calls to the binaries are made
# and AFTER the service has been defined
# to ensure the correct running version of PostgreSQL
# Only exception to this rule is "initdb" call few lines up because this should
# run only on new installation at which point we expect to have correct binaries.
include_recipe 'manifold::postgresql-bin'

execute "/opt/manifold/bin/manifold-ctl start postgresql" do
  retries 20
end

###
# Create the database, migrate it, and create the users we need, and grant them
# privileges.
###

# This template is needed to make the manifold-psql script and PgHelper work
template "/opt/manifold/etc/manifold-psql-rc" do
  owner 'root'
  group svc_group
end

pg_port = node['manifold']['postgresql']['port']
database_name = node['manifold']['manifold-api']['db_database']
manifold_sql_user = node['manifold']['postgresql']['sql_user']
sql_replication_user = node['manifold']['postgresql']['sql_replication_user']

if node['manifold']['manifold-api']['enable']
  execute "create #{manifold_sql_user} database user" do
    command %[/opt/manifold/bin/manifold-psql -d template1 -c "CREATE USER #{manifold_sql_user} WITH SUPERUSER"]
    user postgresql_user
    # Added retries to give the service time to start on slower systems
    retries 20
    not_if { !pg_helper.is_running? || pg_helper.user_exists?(manifold_sql_user) }
  end

  execute "create #{database_name} database" do
    command "/opt/manifold/embedded/bin/createdb --port #{pg_port} -h #{postgresql_socket_dir} -O #{manifold_sql_user} #{database_name}"
    user postgresql_user
    retries 30
    not_if { !pg_helper.is_running? || pg_helper.database_exists?(database_name) }
  end

  execute "create #{sql_replication_user} replication user" do
    command "/opt/manifold/bin/manifold-psql -d template1 -c \"CREATE USER #{sql_replication_user} REPLICATION\""
    user postgresql_user
    # Added retries to give the service time to start on slower systems
    retries 20
    not_if { !pg_helper.is_running? || pg_helper.user_exists?(sql_replication_user) }
  end
end
