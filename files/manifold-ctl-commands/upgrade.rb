add_command 'upgrade', 'Run migrations after a package upgrade', 1 do |cmd_name|
  warn "TBI:: upgrade:#{cmd_name}"
end
