account_helper = AccountHelper.new(node)

puma_service 'puma' do
  rails_app 'manifold-api'
  static_etc_dir "/opt/manifold/etc/manifold/api"
  user account_helper.manifold_user
end

sysctl "net.core.somaxconn" do
  value node['manifold']['puma']['somaxconn']
end
