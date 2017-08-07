Manifold[:node] = node

if File.exists?('/etc/manifold/manifold.rb')
  Manifold.from_file('/etc/manifold/manifold.rb')
end

node.consume_attributes(Manifold.generate_config(node['fdqn']))
