redis_service 'redis' do
  socket_group AccountHelper.new(node).manifold_group
end
