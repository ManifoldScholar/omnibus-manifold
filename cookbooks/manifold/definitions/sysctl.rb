define :sysctl, value: nil do
  name = params[:name]
  value = params[:value]

  directory "create /etc/sysctl.d for #{name}" do
    path "/etc/sysctl.d"
    mode "0755"
    recursive true
  end

  conf_name = "90-omnibus-manifold-#{name}.conf"

  file "create /opt/manifold/embedded/etc/#{conf_name} #{name}" do
    path "/opt/manifold/embedded/etc/#{conf_name}"
    content "#{name} = #{value}\n"
    notifies :run, "execute[load sysctl conf #{name}]", :immediately
  end

  link "/etc/sysctl.d/#{conf_name}" do
    to "/opt/manifold/embedded/etc/#{conf_name}"
  end

  # Remove old (not-used) configs
  [
      "/etc/sysctl.d/90-postgresql.conf",
      "/etc/sysctl.d/90-unicorn.conf",
      "/opt/manifold/embedded/etc/90-omnibus-manifold.conf",
      "/etc/sysctl.d/90-omnibus-manifold.conf"
  ].each do |conf|
    file "delete #{conf} #{name}" do
      path conf
      action :delete
      only_if { File.exists?(conf) }
    end
  end

  # Load the settings right away unless we're on OSX. OSX's version of sysctl does not
  # include an option for setting values from STDIN.
  # TODO: Figure out a solution for parsing the conf files and setting values in OSX.
  if node[:platform] == "mac_os_x"
    load_cmd = ":"
  else
    load_cmd = "cat /etc/sysctl.conf /etc/sysctl.d/*.conf  | sysctl -e -p -"
  end

  execute "load sysctl conf #{name}" do
    command load_cmd
    action :nothing
  end
end
