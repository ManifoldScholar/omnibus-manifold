#
# Copyright:: Copyright (c) 2012 Opscode, Inc.
# Copyright:: Copyright (c) 2014 manifold.com
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
account_helper = AccountHelper.new(node)
omnibus_helper = OmnibusHelper.new(node)

manifold_api_source_dir         = "/opt/manifold/embedded/src/api"
manifold_api_dir                = node['manifold']['manifold-api']['dir']
manifold_api_etc_dir            = File.join(manifold_api_dir, "etc")
manifold_api_static_etc_dir     = "/opt/manifold/etc/manifold/api"
manifold_api_working_dir        = File.join(manifold_api_dir, "working")
manifold_api_tmp_dir            = File.join(manifold_api_dir, "tmp")
manifold_api_tus_data_dir       = node['manifold']['manifold-api']['tus_directory']
manifold_api_public_uploads_dir = node['manifold']['manifold-api']['uploads_directory']
manifold_api_keys_directory     = node['manifold']['manifold-api']['keys_directory']
manifold_api_log_dir            = node['manifold']['manifold-api']['log_directory']
upgrade_status_dir             = File.join(manifold_api_dir, "upgrade-status")

manifold_user = account_helper.manifold_user
manifold_group = account_helper.manifold_group

root_user = "root"
if node[:platform] == "mac_os_x"
  root_group = "wheel"
else
  root_group = "root"
end

# Explicitly try to create directory holding the logs to make sure
# that the directory is created with correct permissions and not fallback
# on umask of the process
directory File.dirname(manifold_api_log_dir) do
  owner manifold_user
  mode '0755'
  recursive true
end

# We create shared_path with 751 allowing other users to enter into the directories
# It's needed, because by default the shared_path is used to store pages which are served by manifold-www:manifold-www
storage_directory node['manifold']['manifold-api']['shared_path'] do
  owner manifold_user
  group account_helper.web_server_group
  mode '0751'
end

[
  manifold_api_tus_data_dir,
  manifold_api_public_uploads_dir,
].compact.each do |dir_name|
  storage_directory dir_name do
    owner manifold_user
    mode '0775'
  end
end

[
  manifold_api_etc_dir,
  manifold_api_static_etc_dir,
  manifold_api_working_dir,
  manifold_api_tmp_dir,
  upgrade_status_dir,
  manifold_api_log_dir,
  manifold_api_keys_directory
].compact.each do |dir_name|
  directory "create #{dir_name}" do
    path dir_name
    owner manifold_user
    mode '0700'
    recursive true
  end
end

directory node['manifold']['manifold-api']['backup_path'] do
  owner manifold_user
  mode '0700'
  recursive true
  only_if { node['manifold']['manifold-api']['manage_backup_path'] }
end

directory manifold_api_dir do
  owner manifold_user
  mode '0755'
  recursive true
end

template File.join(manifold_api_static_etc_dir, "manifold-api-rc")

dependent_services = []
dependent_services << "service[puma]" if omnibus_helper.should_notify?("puma")
dependent_services << "service[cable]" if omnibus_helper.should_notify?("cable")
dependent_services << "service[sidekiq]" if omnibus_helper.should_notify?("sidekiq")

redis_not_listening = omnibus_helper.not_listening?("redis")
postgresql_not_listening = omnibus_helper.not_listening?("postgresql")

templatesymlink "Create a database.yml and create a symlink to Rails root" do
  link_from File.join(manifold_api_source_dir, "config/database.yml")
  link_to File.join(manifold_api_etc_dir, "database.yml")
  source "database.yml.erb"
  owner root_user
  group root_group
  mode "0644"
  variables node['manifold']['manifold-api'].to_hash
  restarts dependent_services
end

# Set up the environment directory
env_dir File.join(manifold_api_static_etc_dir, 'env') do
  rails_env = {
    'HOME'      => node['manifold']['user']['home'],
    'RAILS_ENV' => node['manifold']['manifold-api']['environment'],
  }

  variables(
    rails_env.merge(node['manifold']['manifold-api']['base_env'])
  )

  restarts dependent_services
end

# replace empty directories in the Git repo with symlinks to /var/opt/manifold
{
  "/opt/manifold/embedded/src/api/tmp" => manifold_api_tmp_dir,
  "/opt/manifold/embedded/src/api/data" => manifold_api_tus_data_dir,
  "/opt/manifold/embedded/src/api/public/system" => manifold_api_public_uploads_dir,
  "/opt/manifold/embedded/src/api/log" => manifold_api_log_dir,
  "/opt/manifold/embedded/src/config/keys" => manifold_api_keys_directory,
}.each do |link_dir, target_dir|
  directory link_dir do
    action :delete
    only_if %[test -d #{link_dir} && test ! -L #{link_dir}]
    recursive
  end

  link link_dir do
    to target_dir
    mode "0775"
  end
end

legacy_sidekiq_log_file = File.join(manifold_api_log_dir, 'sidekiq.log')

link legacy_sidekiq_log_file do
  to File.join(node['manifold']['sidekiq']['log_directory'], 'current')
  not_if { File.exists?(legacy_sidekiq_log_file) }
end

# Make schema.rb writable for when we run `rake db:migrate`
file "/opt/manifold/embedded/src/api/db/schema.rb" do
  owner manifold_user
end

# If a version of ruby changes restart puma. If not, puma will fail to
# reload until restarted
file File.join(manifold_api_dir, "RUBY_VERSION") do
  content VersionHelper.version("/opt/manifold/embedded/bin/ruby --version")

  notifies :restart, "service[puma]" if omnibus_helper.should_notify?('puma')
end
