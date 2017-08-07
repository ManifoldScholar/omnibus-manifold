account_helper = AccountHelper.new(node)
webserver_username = account_helper.web_server_user
webserver_group = account_helper.web_server_group
external_webserver_users = node['manifold']['web-server']['external_users'].to_a

account "Webserver user and group" do
  username  webserver_username
  uid       node['manifold']['web-server']['uid']
  ugid      webserver_group
  groupname webserver_group
  gid       node['manifold']['web-server']['gid']
  shell     node['manifold']['web-server']['shell']
  home      node['manifold']['web-server']['home']

  append_to_group external_webserver_users.any?
  group_members   external_webserver_users
  user_supports   manage_home: false

  manage node['manifold']['manage-accounts']['enable']
end
