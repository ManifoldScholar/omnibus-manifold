Manifold[:node] = node

if File.exists?('/etc/manifold/manifold.rb')
  Manifold.from_file('/etc/manifold/manifold.rb')
end

# In v12, Chef changed how deep merging hashes works so that nil values will clear the
# corresponding value in the hash that we're merging into. Our code was written prior to
# this change, and doesn't expect this behavior. Rather than updating our code, we'll
# remove nil values from our hash before we pass it to the node.
def deep_compact(hash)
  res_hash = hash.map do |key, value|
    value = deep_compact(value) if value.is_a?(Hash)

    value = nil if [{}, []].include?(value)
    [key, value]
  end

  res_hash.to_h.compact
end

new_attributes = Manifold.generate_config(node['fdqn'])
node.consume_attributes(deep_compact(new_attributes))
