#
# Copyright 2016 Chef Software, Inc.
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

#
# nodejs-binary provides nodejs using the binary packages provided by
# the upstream.  It does not install it into any of our standard
# paths, so builds that require nodejs need to add embedded/nodejs/bin
# to their path.
#
# Since nodejs is often a build-time-only dependency, it can then be
# easily removed with remove-nodejs.
#
name "nodejs-binary"
default_version "8.15.0"

license "MIT"
license_file "LICENSE"
skip_transitive_dependency_licensing true

version "8.15.0" do
  source_hash = if ppc64le?
                  "0a82cd81f13e59811c02dd12b7446fb2d5be86182dd9a6e96bf4fa32296a192a"
                elsif ppc64?
                  "ef9db73a1c84129b0549db54299569eb308e5992a1459fe27f5c4c8c7184b382"
                elsif s390x?
                  "c68bf544c3998cfa7803811e3c03ec74077a5a57c15ef487ff847c395c6a35fc"
                elsif osx?
                  "a393971136408f837fbc0f7d71a63754f91cfb1851d48bd612d8219eb61956f1"
                else
                  "dc004e5c0f39c6534232a73100c194bc1446f25e3a6a39b29e2000bb3d139d52"
                end
  source sha256: source_hash
end

arch_ext = if ppc64le?
             "linux-ppc64le"
           elsif ppc64?
             "linux-ppc64"
           elsif s390x?
             "linux-s390x"
           elsif osx?
             "darwin-x64"
           else
             "linux-x64"
           end

source url: "https://nodejs.org/dist/v#{version}/node-v#{version}-#{arch_ext}.tar.gz"
relative_path "node-v#{version}-#{arch_ext}"

build do
  mkdir "#{install_dir}/embedded/nodejs"
  sync "#{project_dir}/", "#{install_dir}/embedded/nodejs"
end
