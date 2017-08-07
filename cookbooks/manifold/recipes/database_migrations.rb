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

omnibus_helper = OmnibusHelper.new(node)

dependent_services = []
dependent_services << "service[puma]" if omnibus_helper.should_notify?("puma")
dependent_services << "service[sidekiq]" if omnibus_helper.should_notify?("sidekiq")

connection_attributes = [
    'db_adapter',
    'db_database',
    'db_host',
    'db_port',
    'db_socket'
].collect { |attribute| node['manifold']['manifold-api'][attribute] }
connection_digest = Digest::MD5.hexdigest(Marshal.dump(connection_attributes))

revision_file = "/opt/manifold/embedded/service/manifold-api/REVISION"
if ::File.exist?(revision_file)
  revision = IO.read(revision_file).chomp
end
upgrade_status_dir = ::File.join(node['manifold']['manifold-api']['dir'], "upgrade-status")
db_migrate_status_file = ::File.join(upgrade_status_dir, "db-migrate-#{connection_digest}-#{revision}")

# TODO: Refactor this into a resource
# Currently blocked due to a bug in Chef 12.6.0
# https://github.com/chef/chef/issues/4537
bash "migrate manifold-api database" do
  code <<-EOH
    set -e
    log_file="#{node['manifold']['manifold-api']['log_directory']}/manifold-api-db-migrate-$(date +%Y-%m-%d-%H-%M-%S).log"
    umask 077
    /opt/manifold/bin/manifold-api db:migrate
    /opt/manifold/bin/manifold-api db:seed
    STATUS=${PIPESTATUS[0]}
    echo $STATUS > #{db_migrate_status_file}
    exit $STATUS
  EOH
  notifies :run, 'execute[enable pg_trgm extension]', :before unless omnibus_helper.not_listening?("postgresql") || !node['manifold']['postgresql']['enable']
  #notifies :run, "execute[clear the manifold-api cache]", :immediately unless omnibus_helper.not_listening?("redis") || !node['manifold']['manifold-api']['rake_cache_clear']
  dependent_services.each do |svc|
    notifies :restart, svc, :immediately
  end
  not_if "(test -f #{db_migrate_status_file}) && (cat #{db_migrate_status_file} | grep -Fx 0)"
  only_if { node['manifold']['manifold-api']['auto_migrate'] }
end
