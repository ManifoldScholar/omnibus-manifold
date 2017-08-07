account_helper = AccountHelper.new(node)
install_dir = node['package']['install-dir']

sidekiq_service 'sidekiq' do
  rails_app 'manifold-api'
  src_dir 'api'
  user account_helper.manifold_user
end
