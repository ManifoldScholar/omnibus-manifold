#
# Copyright 2013-2014 Chef Software, Inc.
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

name "jre"
default_version "8u152"

unless _64_bit?
  raise "Server-jre can only be installed on x86_64 systems."
end

license "Oracle-Binary"
license_file "LICENSE"
#
# October 2016 (ssd):
# Unfortunately http://java.com/license/ redirects to https://java.com/license/
# which then redirects to http://www.oracle.com/technetwork/java/javase/terms/license/
# triggering a bad redirect error.
#
license_file "http://www.oracle.com/technetwork/java/javase/terms/license/"
skip_transitive_dependency_licensing true

whitelist_file "jre/bin/javaws"
whitelist_file "jre/bin/policytool"
whitelist_file "jre/lib"
whitelist_file "jre/plugin"
whitelist_file "jre/bin/appletviewer"

license_warning = "By including the JRE, you accept the terms of the Oracle Binary Code License Agreement for the Java SE Platform Products and JavaFX, which can be found at http://www.oracle.com/technetwork/java/javase/terms/license/index.html"
license_cookie = "gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie"

version "8u152" do
  if mac_os_x?
    # https://www.oracle.com/webfolder/s/digest/8u121checksum.html
    source url: "http://download.oracle.com/otn-pub/java/jdk/8u152-b16/aa0333dd3019491ca4f6ddbe78cdb6d0/jre-8u152-macosx-x64.tar.gz",
           sha256: "4f00316e9d69bfb5f44a4831c17e9e96350f3724dbc70d97f8eaf6fe9fee13ca",
           cookie: license_cookie,
           warning: license_warning,
           unsafe:  true
    relative_path "jre1.8.0_152.jre/Contents/Home"
  else
    source url: "http://download.oracle.com/otn-pub/java/jdk/8u152-b16/aa0333dd3019491ca4f6ddbe78cdb6d0/jre-8u152-linux-x64.tar.gz",
           sha256: "ed04ffbf8050a69b15f02c51a2cae8e0de9362e7f6fe8995b1c39c613fc20ede",
           cookie: license_cookie,
           warning: license_warning,
           unsafe:  true
    relative_path "jre1.8.0_152"
  end
end

build do
  mkdir "#{install_dir}/embedded/jre"
  sync  "#{project_dir}/", "#{install_dir}/embedded/jre"
end
