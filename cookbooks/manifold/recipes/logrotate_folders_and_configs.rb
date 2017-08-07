#
# Copyright:: Copyright (c) 2014 GitLab B.V.
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
