define :storage_directory, path: nil, owner: 'root', group: nil, mode: nil do
  next unless node['manifold']['manage-storage-directories']['enable']

  params[:path] ||= params[:name]
  storage_helper = StorageDirectoryHelper.new(params[:owner], params[:group], params[:mode])

  ruby_block "directory resource: #{params[:path]}" do
    block do
      # Ensure the directory exists
      storage_helper.ensure_directory_exists(params[:path])

      # Ensure the permissions are set
      storage_helper.ensure_permissions_set(params[:path])

      # Error out if we have not achieved the target permissions
      storage_helper.validate!(params[:path])
    end
    not_if { storage_helper.validate(params[:path]) }
  end
end
