bootstrap_status_file = "/var/opt/manifold/bootstrapped"

if node[:platform] == "mac_os_x"
  svc_group = "wheel"
else
  svc_group = "root"
end

file bootstrap_status_file do
  owner "root"
  group svc_group
  mode "0600"
  content "Manifold has been bootstrapped"
end
