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
default_version "8.10.0"

license "MIT"
license_file "LICENSE"
skip_transitive_dependency_licensing true

version "8.10.0" do
  source_hash = if ppc64le?
                  "f3daa7c32c5ea92176821b87e4f7653de6c181cca2d87904f6a1d3b25864d623"
                elsif ppc64?
                  "0cf3170dfd8cf489a8e17dfa525927ba927fe3022a1ef2c924affffce7c82691"
                elsif s390x?
                  "f225806b120564dadc9f1194d4360a311ffb374e3ffd0bcf6da0a9bfeeb670bc"
                elsif osx?
                  "7d77bd35bc781f02ba7383779da30bd529f21849b86f14d87e097497671b0271"
                else
                  "c1302439aee9791d70d3ab4194a612e6131d37fa0e3452072e847e212ed77867"
                end
  source sha256: source_hash
end

version "6.10.3" do
  source_hash = if ppc64le?
                  "de8e4ca71caa8be6eaf80e65b89de2a6d152fa4ce08efcbc90ce7e1bfdf130e7"
                elsif ppc64?
                  "e8ce540b592d337304a10f4eb19bb4efee889c6676c5f188d072bfb2a8089927"
                elsif s390x?
                  "e0f2616b4beb4c2505edb19e3cbedbf3d1c958441517cc9a1e918f6feaa4b95b"
                elsif osx?
                  "c09b2e60b7c12d88199d773f7ce046a6890e7c5d3be0cf68312ae3da474f32a2"
                else
                  "c6a60f823a4df31f1ed3a4044d250e322f2f2794d97798d47c6ee4af9376f927"
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
