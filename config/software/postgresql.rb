#
# Copyright 2012-2014 Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

name "postgresql"
default_version "9.6.3"

license "PostgreSQL"
license_file "COPYRIGHT"
skip_transitive_dependency_licensing true

dependency "zlib"
dependency "openssl"
dependency "libedit"
dependency "ncurses"
dependency "config_guess"

if osx?
  dependency "libossp-uuid"
else
  dependency "libuuid"
end


version "9.5.1" do
  source md5: "11e037afaa4bd0c90bb3c3d955e2b401"
end

version "9.4.6" do
  source md5: "0371b9d4fb995062c040ea5c3c1c971e"
end

version "9.6.3" do
  source md5: "ce1d0a57ace0a5b7a994b56796fdba35"
end

source url: "https://ftp.postgresql.org/pub/source/v#{version}/postgresql-#{version}.tar.bz2"

relative_path "postgresql-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  prefix = "#{install_dir}/embedded/postgresql/#{version}"

  update_config_guess(target: "config")

  config_args = [
    "--prefix=#{prefix}",
    "--with-libedit-preferred",
    "--with-openssl",
    "--with-includes=#{install_dir}/embedded/include",
    "--with-libraries=#{install_dir}/embedded/lib",
    "--with-uuid=e2fs"
  ]

  command "./configure #{config_args.join(' ')}", env: env

  make "world -j #{workers}", env: env
  make "install-world", env: env

  block 'link bin files' do
    Dir.glob("#{prefix}/bin/*").each do |bin_file|
      link bin_file, "#{install_dir}/embedded/bin/#{File.basename(bin_file)}"
    end
  end
end
