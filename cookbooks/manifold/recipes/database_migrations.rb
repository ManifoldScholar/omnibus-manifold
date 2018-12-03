#
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
require 'digest'
require 'fileutils'

omnibus_helper = OmnibusHelper.new(node)

dependent_services = []
dependent_services << "service[cable]" if omnibus_helper.should_notify?("cable")
dependent_services << "service[clockwork]" if omnibus_helper.should_notify?("clockwork")
dependent_services << "service[puma]" if omnibus_helper.should_notify?("puma")
dependent_services << "service[sidekiq]" if omnibus_helper.should_notify?("sidekiq")

src_dir               = node['manifold']['manifold-api']['src']
current_schema_file   = File.join(src_dir, 'db', 'schema.rb')
previous_schema_file  = File.join(src_dir, 'db', 'previous_schema.rb')

# TODO: Refactor this into a resource
# Currently blocked due to a bug in Chef 12.6.0
# https://github.com/chef/chef/issues/4537
bash "migrate manifold-api database" do
  code <<-EOH
    set -e
    cp -v #{current_schema_file} #{previous_schema_file}
    log_file="#{node['manifold']['manifold-api']['log_directory']}/manifold-api-db-migrate-$(date +%Y-%m-%d-%H-%M-%S).log"
    umask 0022
    /opt/manifold/bin/manifold-api db:migrate
    /opt/manifold/bin/manifold-api db:seed
  EOH

  notifies :run, 'execute[post-migration notification]', :immediately

  only_if { node['manifold']['manifold-api']['auto_migrate'] }
end

execute "post-migration notification" do
  action :nothing

  command "echo 'restarting services that depend on the database'"

  not_if { File.exists?(previous_schema_file) && FileUtils.cmp(current_schema_file, previous_schema_file) }

  dependent_services.each do |svc|
    notifies :restart, svc, :immediately
  end
end
