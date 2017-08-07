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
if File.exist?('/.dockerenv')
  Chef::Log.warn "Skipped selecting an init system because it looks like we are running in a container"
elsif node[:platform] == "mac_os_x"
  include_recipe "runit::launchd"
elsif system('/sbin/init --version 2>/dev/null | grep -q upstart')
  Chef::Log.warn "Selected upstart because /sbin/init --version is showing upstart."
  include_recipe "runit::upstart"
elsif system('systemctl | grep -q "\-\.mount"')
  Chef::Log.warn "Selected systemd because systemctl shows .mount units"
  include_recipe "runit::systemd"
else
  Chef::Log.warn "Selected sysvinit because it looks like it is not upstart or systemd."
  include_recipe "runit::sysvinit"
end
