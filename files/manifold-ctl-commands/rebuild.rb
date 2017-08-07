def run_command(command)
  system(command)
  $?
end

add_command_under_category "rebuild-server", "rebuild", "Rebuild the client node server from source", 2 do |command|
  warn "Rebuilding the node servers"
  Dir.chdir('/opt/manifold/embedded/src/client') do
    run_command("rm dist/node/env.js") if File.exist?("dist/node/env.js")
    run_command("/opt/manifold/embedded/bin/yarn run build:servers")
    run_command("rm dist/node/env.js") if File.exist?("dist/node/env.js")
    run_command("ln -s /var/opt/manifold/etc/node-env.js dist/node/env.js")
  end
end

add_command_under_category "rebuild-client", "rebuild", "Rebuild the client javascript from source", 2 do |command|
  warn "Rebuilding the client javascript"
  Dir.chdir('/opt/manifold/embedded/src/client') do
    run_command("rm dist/www/build/env.js") if File.exist?("dist/www/build/env.js")
    run_command("/opt/manifold/embedded/bin/yarn run build:client")
    run_command("rm dist/www/build/env.js") if File.exist?("dist/www/build/env.js")
    run_command("ln -s /var/opt/manifold/etc/browser-env.js dist/www/build/env.js")
  end
end