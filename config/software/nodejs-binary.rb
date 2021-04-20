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
default_version "12.22.1"

license "MIT"
license_file "LICENSE"
skip_transitive_dependency_licensing true

version "12.22.1" do
  source_hash = if ppc64le?
                  "376f76be1e2512a6b6a69aadca063b2b64e476869da8c30c8c649303c2c19aa8"
                elsif ppc64?
                  "9b62fcc3138eaadfc4ea90776c5e02f508a1d7df8c0b1692734cd9d07a7d82dd"
                elsif s390x?
                  "b658a78b1c194e9faf1b6955e1fd7eacaad228698a6b4744ffc6d44ffa31e74c"
                else
                  "d315c5dea4d96658164cdb257bd8dbb5e44bdd2a7c1d747841f06515f23a0042"
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
