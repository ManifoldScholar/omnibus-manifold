pg_helper               = PgHelper.new(node)
omnibus_helper          = OmnibusHelper.new(node)
postgresql_install_dir  = File.join(node['package']['install-dir'], 'embedded/postgresql')
postgresql_data_dir     = node['manifold']['postgresql']['data_dir']

# This recipe will also be called standalone so the resource
# won't exist for resource collection.
# We only have ourselves to blame here, we want DRY code this is what we get.
# The block below is cleanest solution and
# was found at https://gist.github.com/scalp42/7606857#gistcomment-1618630
resource_exists = proc do |name|
  begin
    resources name
    true
  rescue Chef::Exceptions::ResourceNotFound
    false
  end
end

ruby_block "Link postgresql bin files to the correct version" do
  block do
    pg_version = pg_helper.database_version || pg_helper.version

    $stdout.puts "PG VERSION :: #{pg_version}"

    pg_path = Dir.glob("#{postgresql_install_dir}/#{pg_version}*").first

    Dir.glob("#{pg_path}/bin/*").each do |pg_bin|
      FileUtils.ln_sf(pg_bin, "#{node['package']['install-dir']}/embedded/bin/#{File.basename(pg_bin)}")
    end
  end

  only_if do
    version_file_does_not_exist = !File.exists?(File.join(postgresql_data_dir, "PG_VERSION"))
    version_mismatched          = pg_helper.version !~ /^#{pg_helper.database_version}/

    version_file_does_not_exist || version_mismatched
  end

  notifies :restart, 'service[postgresql]', :immediately if omnibus_helper.should_notify?("postgresql") && resource_exists['service[postgresql]']
end
