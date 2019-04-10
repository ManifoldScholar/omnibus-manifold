define :account, action: nil, username: nil, uid: nil, ugid: nil, groupname: nil, gid: nil, shell: nil, home: nil, system: true, append_to_group: false, group_members: [], manage_home: true, non_unique: false, manage: nil do

  manage = params[:manage]

  groupname = params[:groupname]
  username = params[:username]

  if manage && groupname
    group params[:name] do
      group_name groupname
      gid params[:gid]
      system params[:system]
      if params[:append_to_group]
        append true
        members params[:group_members]
      end
      action params[:action]
    end
  end

  if manage && username
    user params[:name] do
      username username
      shell params[:shell]
      home params[:home]
      uid params[:uid]
      gid params[:ugid]
      system params[:system]
      manage_home params[:manage_home]
      non_unique params[:non_unique]
      action params[:action]
    end

    # We don't want to show Manifold service users on the login screen.
    if node[:platform] == "mac_os_x"
      execute "sudo dscl . create /Users/#{username} IsHidden 1" do
        retries 1
      end
    end

  end
end
