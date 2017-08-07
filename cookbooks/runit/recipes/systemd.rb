directory '/usr/lib/systemd/system' do
  recursive true
end

cookbook_file "/usr/lib/systemd/system/manifold-runsvdir.service" do
  mode "0644"
  source "manifold-runsvdir.service"
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
  notifies :run, 'execute[systemctl enable manifold-runsvdir]', :immediately
  notifies :run, 'execute[systemctl start manifold-runsvdir]', :immediately
end

# Remove old symlink
file "/etc/systemd/system/default.target.wants/manifold-runsvdir.service" do
  action :delete
end

execute "systemctl daemon-reload" do
  action :nothing
end

execute "systemctl enable manifold-runsvdir" do
  action :nothing
end

execute "systemctl start manifold-runsvdir" do
  action :nothing
end
