account_helper = AccountHelper.new(node)

puma_service 'cable' do
  rails_app 'manifold-api'
  static_etc_dir "/opt/manifold/etc/manifold/api"
  config_template "cable.rb.erb"
  user account_helper.manifold_user
end
