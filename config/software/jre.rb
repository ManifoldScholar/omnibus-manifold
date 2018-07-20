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
default_version "8u181"

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

version "8u181" do
  if mac_os_x?
    # https://www.oracle.com/webfolder/s/digest/8u121checksum.html
    source url: "http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jre-8u181-macosx-x64.tar.gz",
           sha256: "7d2e6275f77bfa0f0eaca03c6d48e27fa822abcae056d30293007978957ce3fc",
           cookie: license_cookie,
           warning: license_warning,
           unsafe:  true
    relative_path "jre1.8.0_181.jre/Contents/Home"
  else
    source url: "http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jre-8u181-linux-x64.tar.gz",
           sha256: "0b26c7fcfad20029e6e0989e678efcd4a81f0fe502a478b4972215533867de1b",
           cookie: license_cookie,
           warning: license_warning,
           unsafe:  true
    relative_path "jre1.8.0_181"
  end
end

build do
  mkdir "#{install_dir}/embedded/jre"
  sync  "#{project_dir}/", "#{install_dir}/embedded/jre"
end
