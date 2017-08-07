#
# Copyright:: Copyright (c) 2016 Manifold Inc.
# License:: Apache License, Version 2.0
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

module Nginx
  DEFAULT_PROXY_HEADERS ||= {
    'https' => {
      'X-Forwarded-Proto' => 'https',
      'X-Forwarded-Ssl'   => 'on'
    },

    'http' => {
      'X-Forwarded-Proto' => 'http'
    }
  }

  class << self
    def parse_variables
      parse_nginx_listen_address
      parse_nginx_listen_ports
    end

    def parse_nginx_listen_address
      return unless Manifold['nginx']['listen_address']

      # The user specified a custom NGINX listen address with the legacy
      # listen_address option. We have to convert it to the new
      # listen_addresses setting.
      Chef::Log.warn "nginx['listen_address'] is deprecated. Please use nginx['listen_addresses']"

      Manifold['nginx']['listen_addresses'] = [Manifold['nginx']['listen_address']]
    end

    def parse_nginx_listen_ports
      [
        [%w{nginx listen_port}, %w{manifold_api manifold_api_port}],
      ].each do |left, right|
        if !Manifold[left.first][left.last].nil?
          next
        end

        default_set_manifold_port = Manifold['node']['manifold'][right.first.gsub('_', '-')][right.last]
        user_set_manifold_port = Manifold[right.first][right.last]

        Manifold[left.first][left.last] = user_set_manifold_port || default_set_manifold_port
      end
    end

    def parse_proxy_headers(app, https)
      values_from_manifold_rb = Hash.try_convert(Manifold[app]['proxy_set_headers']) || {}

      default_from_attributes = Manifold['node']['manifold'][app.gsub('_', '-')]['proxy_set_headers'].to_hash

      default_from_attributes.merge!(DEFAULT_PROXY_HEADERS[https ? 'https' : 'http'])

      if values_from_manifold_rb
        values_from_manifold_rb.each do |key, value|
          default_from_attributes.delete(key) if value.nil?
        end

        default_from_attributes = default_from_attributes.merge(values_from_manifold_rb.to_hash)
      end

      Manifold[app]['proxy_set_headers'] = default_from_attributes
    end

    # @return [{String => String}]
    def parse_error_pages
      {}.tap do |errors|
        # At the least, provide error pages for 404, 402, 500, 502 errors

        %w(404 422 500 502).each_with_object(errors) do |err, hsh|
          hsh[err] = "#{err}.html"
        end

        if Manifold['nginx'].key?('custom_error_pages')
          Manifold['nginx']['custom_error_pages'].each_key do |err|
            errors[err] = "#{err}-custom.html"
          end
        end
      end
    end
  end
end
