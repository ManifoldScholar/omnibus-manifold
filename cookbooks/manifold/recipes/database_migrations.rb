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

port = node['manifold']['elasticsearch']['port']
bind = node['manifold']['elasticsearch']['bind']
elasticsearch_url_parts = ["http://"]
elasticsearch_url_parts << bind
elasticsearch_url_parts << ":#{port}" if port
elasticsearch_url = elasticsearch_url_parts.join("")

dependent_services = []
dependent_services << "service[cable]" if omnibus_helper.should_notify?("cable")
dependent_services << "service[clockwork]" if omnibus_helper.should_notify?("clockwork")
dependent_services << "service[puma]" if omnibus_helper.should_notify?("puma")
dependent_services << "service[sidekiq]" if omnibus_helper.should_notify?("sidekiq")

src_dir               = node['manifold']['manifold-api']['src']
current_schema_file   = File.join(src_dir, 'db', 'schema.rb')
previous_schema_file  = File.join(src_dir, 'db', 'previous_schema.rb')

# Redis needs to be running for migrations to work correctly.
execute "redis-start" do
  command "/opt/manifold/bin/manifold-ctl start redis"

  retries 20

  notifies :run, "bash[redis-wait]", :immediately
end

bash "redis-wait" do
  action :nothing

  code <<~EOH
  set -x

  response=$(#{omnibus_helper.redis_cli_command("ping")})

  [ "${response}" = "PONG" ]
  EOH

  retries 20

  retry_delay 5

  notifies :run, "execute[elasticsearch-start]", :immediately
end

execute "elasticsearch-start" do

  action :nothing

  command "/opt/manifold/bin/manifold-ctl start elasticsearch"

  retries 20

  notifies :run, "execute[elasticsearch-wait]", :immediately
end

execute "elasticsearch-wait" do
  command "curl -s #{elasticsearch_url}"

  action :nothing

  retries 20

  retry_delay 5

  notifies :run, "bash[migrate manifold-api database]", :immediately
end

bash "migrate manifold-api database" do
  action :nothing

  code <<-EOH
    set -e
    cp -v #{current_schema_file} #{previous_schema_file}
    log_file="#{node['manifold']['manifold-api']['log_directory']}/manifold-api-db-migrate-$(date +%Y-%m-%d-%H-%M-%S).log"
    umask 0022
    /opt/manifold/bin/manifold-api db:migrate
    /opt/manifold/bin/manifold-api db:seed
    /opt/manifold/bin/manifold-api manifold:upgrade
  EOH

  notifies :run, 'execute[post-migration notification]', :immediately
end

execute "post-migration notification" do
  action :nothing

  command "echo 'restarting services that depend on the database'"

  dependent_services.each do |svc|
    notifies :restart, svc, :immediately
  end

end
