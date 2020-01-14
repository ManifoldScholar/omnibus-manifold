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
default_version "12.14.0"

license "MIT"
license_file "LICENSE"
skip_transitive_dependency_licensing true

version "12.14.0" do
  source_hash = if ppc64le?
                  "c00134ae7cee96b5c2782dabc1c3b778b3bc2cf8d53702c63d2e46966bb8cc39"
                elsif ppc64?
                  "b1c4db193ac9981d671a8b267d4d836dcdb20d9d0a9fa1b69150c349a5ac5b39"
                elsif s390x?
                  "82458edb46ef0ca410c4c21b0a002ee1098a3cc422e3cdf032aa96c9ed49425e"
                else
                  "52207f643ab0fba66d5189a51aac280c4834c81f24a7297446896386ec93a5ed"
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
