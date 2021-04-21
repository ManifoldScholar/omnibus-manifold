resource_name :templatesymlink
provides :templatesymlink

actions :create, :delete
default_action :create

property :link_from, String
property :link_to, String
property :source, String
property :owner, String
property :group, String
property :mode, String
property :variables, Hash, default: {}
property :helpers, Module, default: SingleQuoteHelper
property :notification_targets, Array
property :restarts, Array, default: []

action :create do
  template new_resource.link_to do
    source new_resource.source
    owner new_resource.owner
    group new_resource.group
    mode new_resource.mode
    variables new_resource.variables
    helpers new_resource.helpers
    notifies *(new_resource.notification_targets) if new_resource.notification_targets
    new_resource.restarts.each do |resource|
      notifies :restart, resource
    end
    action :create
  end

  link "Link #{new_resource.link_from} to #{new_resource.link_to}" do
    target_file new_resource.link_from
    to new_resource.link_to
    action :create
    new_resource.restarts.each do |resource|
      notifies :restart, resource
    end
  end
end

action :delete do
  template link_to do
    action :delete
  end

  link "Link #{link_from} to #{link_to}" do
    action :delete
  end
end
