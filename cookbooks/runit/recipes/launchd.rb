#
# Cookbook Name:: runit
# Recipe:: default
#
# Copyright 2008-2010, Opscode, Inc.
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

directory '/var/log/manifold/launchd' do
  recursive true
end

cookbook_file "/Library/LaunchDaemons/org.manifold.runit.plist" do
  owner "root"
  group "wheel"
  mode "0644"
  source "org.manifold.runit.plist"
  notifies :run, 'execute[launchctl load -w /Library/LaunchDaemons/org.manifold.runit.plist]', :immediately
end

execute "launchctl load -w /Library/LaunchDaemons/org.manifold.runit.plist" do
  action :nothing
end

