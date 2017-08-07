require 'digest'

name "manifold-psql"

license "Apache-2.0"
license_file File.expand_path("LICENSE", Omnibus::Config.project_root)

# This 'software' is self-contained in this file. Use the file contents
# to generate a version string.
default_version Digest::MD5.file(__FILE__).hexdigest

build do
  block do
    open("#{install_dir}/bin/manifold-psql", "w") do |file|
      file.print <<-EOH
#!/bin/sh

error_echo()
{
  echo "$1" 2>& 1
}

manifold_psql_rc='#{install_dir}/etc/manifold-psql-rc'


if ! [ -f ${manifold_psql_rc} ] ; then
  error_echo "$0 error: could not load ${manifold_psql_rc}"
  error_echo "Either you are not allowed to read the file, or it does not exist yet."
  error_echo "You can generate it with:   sudo manifold-ctl reconfigure"
  exit 1
fi

. ${manifold_psql_rc}

if [ "$(id -n -u)" = "${psql_user}" ] ; then
  privilege_drop=''
else
  privilege_drop="-u ${psql_user}"
fi

exec #{install_dir}/embedded/bin/chpst ${privilege_drop} -U ${psql_user} #{install_dir}/embedded/bin/psql -p ${psql_port} -h ${psql_host} "$@"
       EOH
    end
  end

  command "chmod 755 #{install_dir}/bin/manifold-psql"
end
