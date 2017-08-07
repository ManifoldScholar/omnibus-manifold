def run_command(command)
  system(command)
  $?
end

def run_sv_command(sv_cmd, service=nil)
  exit_status = 0
  sv_cmd = "1" if sv_cmd == "usr1"
  sv_cmd = "2" if sv_cmd == "usr2"
  if service
    exit_status += run_sv_command_for_service(sv_cmd, service)
  else
    get_all_services.each do |service_name|
      exit_status += run_sv_command_for_service(sv_cmd, service_name) if global_service_command_permitted(sv_cmd, service_name)
    end
  end
  exit! exit_status
end

def exit!(code)
  @force_exit = true
  code
end

def macOS?
  RUBY_PLATFORM.include? "darwin"
end

def log(msg)
  fh_output.puts msg
end

def get_all_services_files
  Dir[File.join(sv_path, '*')]
end

def get_all_services
  get_all_services_files.map { |f| File.basename(f) }.sort
end

def stop_services
  log "Shutting down Manifold services"
  run_sv_command("stop")
end

def stop_supervisor
  if macOS?
    stop_supervisor_launchd
    return
  end
  stop_supervisor_init
end

def stop_supervisor_launchd
  path = "/Library/LaunchDaemons/org.manifold.runit.plist"
  return log "#{path} does not exist. Moving on" unless File.exists?(path)
  log "Shutting down runit supervisor process with launchctl"
  run_command("launchctl unload #{path}")
  run_command("rm #{path}")
end

def stop_supervisor_init
  FileUtils.rm_f("/etc/init/#{name}-runsvdir.conf") if File.exists?("/etc/init/#{name}-runsvdir.conf")
  run_command("egrep -v '#{base_path}/embedded/bin/runsvdir-start' /etc/inittab > /etc/inittab.new && mv /etc/inittab.new /etc/inittab") if File.exists?("/etc/inittab")
  run_command("kill -1 1")
end

def kill_processes
  get_all_services.each do |die_daemon_die|
    cmd = "pkill -KILL -f 'runsv #{die_daemon_die}'"
    log "Executing: #{cmd}"
    run_command(cmd)
  end
end

def remove_path(path)
  cmd = "rm -rf #{path}"
  log "Executing: #{cmd}"
  run_command(cmd)
end

def remove_service_path
  raise "Invalid remove path" if base_path.nil? || base_path.empty? || base_path == "/"
  remove_path(base_path)
end

def remove_log_path
  raise "Invalid remove path" if name.nil? || name.empty?
  path = "/var/log/#{name}"
  remove_path(path)
end

def remove_data_path
  raise "Invalid remove path" if name.nil? || name.empty?
  path = "/var/opt/#{name}"
  remove_path(path)
end

def remove_config_path
  raise "Invalid remove path" if name.nil? || name.empty?
  path = "/etc/#{name}"
  remove_path(path)
end

def remove_symlinks
  run_command("rm /usr/local/bin/manifold-ctl")
  run_command("rm /usr/local/bin/manifold-api")
  run_command("rm /usr/local/bin/manifold-rake")
  run_command("rm /usr/local/bin/manifold-psql")
end

desc = "Kill all processes and uninstall the process supervisor (data will be preserved)."
add_command "uninstall", desc, 1 do |command|
  stop_services
  stop_supervisor
  kill_processes
  exit! 0
end

desc = "Delete *all* #{display_name} data, and start from scratch."
add_command "cleanse", desc, 1 do |command|
  log <<EOM
*******************************************************************
* * * * * * * * * * *       STOP AND READ       * * * * * * * * * *
*******************************************************************
This command will delete *all* local configuration, log, and
variable data associated with #{display_name}.

To back out, hit CTRL-C. To proceeed, type the word "manifold". and
press return. After doing this, configuration, logs, and data for 
this application will be permanently deleted.
*******************************************************************

Type the word "manifold" to proceed:
EOM
  confirmed = STDIN.gets.chomp
  if confirmed == "manifold"
    stop_services
    stop_supervisor
    kill_processes
    remove_service_path
    remove_log_path
    remove_data_path
    remove_config_path
    remove_symlinks
  else
    log "Cleanse cancelled."
  end
  exit! 0
end
