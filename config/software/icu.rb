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

name "icu"

# Starting with v59.1, icu requires GCC 4.9 to compile. Centos7 included GCC 4.8.
default_version "58.3"

version "58.3" do
  source url: "https://github.com/unicode-org/icu/releases/download/release-58-3/icu4c-58_3-src.tgz",
         sha512: "efb3baa32bd01b1b2c63bed9d077c4df4df76db8c6007b50bb7de642df6e6723def2e7180712efdc1df763d89c3a22aa7f470c07c4a099ac9e647762448fd541"
end

version "69.1" do
  source url: "https://github.com/unicode-org/icu/releases/download/release-69-1/icu4c-69_1-src.tgz",
         sha512: "d4aeb781715144ea6e3c6b98df5bbe0490bfa3175221a1d667f3e6851b7bd4a638fa4a37d4a921ccb31f02b5d15a6dded9464d98051964a86f7b1cde0ff0aab7"
end

relative_path "icu/source"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure --prefix=#{install_dir}/embedded", env: env
  make "-j #{workers}", env: env
  make "install", env: env
end
