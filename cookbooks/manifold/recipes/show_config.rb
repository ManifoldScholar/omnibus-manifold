if File.exists?('/etc/manifold/manifold.rb')
  Manifold[:node] = node
  Manifold.from_file('/etc/manifold/manifold.rb')
end

config = Manifold.generate_config(node['fdqn'])

puts Chef::JSONCompat.to_json_pretty(config)
return
