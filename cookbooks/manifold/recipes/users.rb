account_helper = AccountHelper.new(node)
manifold_username = account_helper.manifold_user
manifold_group = account_helper.manifold_group
manifold_home = node['manifold']['user']['home']

account "Manifold user and group" do
  username manifold_username
  uid node['manifold']['user']['uid']
  ugid manifold_group
  groupname manifold_group
  gid node['manifold']['user']['gid']
  shell node['manifold']['user']['shell']
  home manifold_home
  manage node['manifold']['manage-accounts']['enable']
end

directory manifold_home do
  recursive true
  owner manifold_username
  group manifold_group
  mode 0755
end
