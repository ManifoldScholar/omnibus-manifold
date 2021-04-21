# Manifold configuration
#
# Attributes here will be applied to configure the application and the services
# it uses.
#
# Most of the attributes in this file are things you will not need to ever
# touch, but they are here in case you need them.
#
# A `manifold-ctl reconfigure` should pick up any changes made here.
#
# Users make changes to /etc/manifold/manifold.rb

# ## Omnibus options
default['manifold']['bootstrap']['enable'] = true

# Create users and groups needed for the package
default['manifold']['manage-accounts']['enable'] = true

# Create directories with correct permissions and ownership required by the pkg
default['manifold']['manage-storage-directories']['enable']      = true
default['manifold']['manage-storage-directories']['manage_etc']  = true

####
# The OS User that services run as
####
default['manifold']['user']['username'] = "manifold"
default['manifold']['user']['group'] = "manifold"
default['manifold']['user']['uid'] = nil
default['manifold']['user']['gid'] = nil
default['manifold']['user']['shell'] = "/bin/sh"
default['manifold']['user']['home'] = "/var/opt/manifold"

####
# Manifold Client (NODE App)
####
default['manifold']['client']['enable'] = true
default['manifold']['client']['dir'] = "/var/opt/manifold/client"
default['manifold']['client']['src'] = "#{node['package']['install-dir']}/embedded/src/client"
default['manifold']['client']['log_directory'] = "/var/log/manifold/client"
default['manifold']['client']['environment'] = 'production'
default['manifold']['client']['socket'] = '/var/opt/manifold/client/sockets/client.sock'
if node[:platform] == "mac_os_x"
  default['manifold']['client']['api_url'] = 'http://localhost:3030'
else
  default['manifold']['client']['api_url'] = 'http://localhost'
end

####
# Manifold API (Rails App)
####
default['manifold']['manifold-api']['enable'] = true
default['manifold']['manifold-api']['dir'] = "/var/opt/manifold/api"
default['manifold']['manifold-api']['src'] = "#{node['package']['install-dir']}/embedded/src/api"
default['manifold']['manifold-api']['log_directory'] = "/var/log/manifold/api"
default['manifold']['manifold-api']['environment'] = 'production'
default['manifold']['manifold-api']['base_env'] = {
  'SIDEKIQ_MEMORY_KILLER_MAX_RSS' => '1000000',
  'MALLOC_ARENA_MAX' => '2',
  'BUNDLE_GEMFILE' => "#{node['package']['install-dir']}/embedded/src/api/Gemfile",
  'PATH' => "#{node['package']['install-dir']}/bin:#{node['package']['install-dir']}/embedded/bin:/usr/local/bin:/bin:/usr/bin",
}
default['manifold']['manifold-api']['env'] = {}
default['manifold']['manifold-api']['enable_jemalloc'] = true
# We don't actually want to expose this in the config.rb, but we configure it here with other shared paths.
default['manifold']['manifold-api']['tus_directory'] = "/var/opt/manifold/api/data"
default['manifold']['manifold-api']['uploads_directory'] = "/var/opt/manifold/api/uploads"
default['manifold']['manifold-api']['keys_directory'] = "/var/opt/manifold/api/keys"
default['manifold']['manifold-api']['auto_migrate'] = true
default['manifold']['manifold-api']['rake_cache_clear'] = true
default['manifold']['manifold-api']['manifold_host'] = node['fqdn']
default['manifold']['manifold-api']['manifold_https'] = false
default['manifold']['manifold-api']['time_zone'] = nil

# You probably do not need to change any of the following settings.
default['manifold']['manifold-api']['shared_path'] = "/var/opt/manifold/api/shared"
default['manifold']['manifold-api']['backup_path'] = "/var/opt/manifold/backups"
default['manifold']['manifold-api']['manage_backup_path'] = true
default['manifold']['manifold-api']['backup_archive_permissions'] = nil
default['manifold']['manifold-api']['backup_pg_schema'] = nil
default['manifold']['manifold-api']['backup_keep_time'] = nil
default['manifold']['manifold-api']['backup_upload_connection'] = nil
default['manifold']['manifold-api']['backup_upload_remote_directory'] = nil
default['manifold']['manifold-api']['backup_multipart_chunk_size'] = nil
default['manifold']['manifold-api']['backup_encryption'] = nil
default['manifold']['manifold-api']['db_adapter'] = "postgresql"
default['manifold']['manifold-api']['db_encoding'] = "unicode"
default['manifold']['manifold-api']['db_collation'] = nil
default['manifold']['manifold-api']['db_database'] = "manifold_production"
default['manifold']['manifold-api']['db_pool'] = 10
default['manifold']['manifold-api']['db_username'] = "manifold"
default['manifold']['manifold-api']['db_password'] = nil
default['manifold']['manifold-api']['db_host'] = "/var/opt/manifold/postgresql"
default['manifold']['manifold-api']['db_port'] = 3034
default['manifold']['manifold-api']['db_socket'] = nil
default['manifold']['manifold-api']['db_sslmode'] = nil
default['manifold']['manifold-api']['db_sslrootcert'] = nil
default['manifold']['manifold-api']['db_sslca'] = nil
default['manifold']['manifold-api']['redis_host'] = "127.0.0.1"
default['manifold']['manifold-api']['redis_port'] = 3035
default['manifold']['manifold-api']['redis_password'] = nil
default['manifold']['manifold-api']['redis_socket'] = "/var/opt/manifold/redis/redis.socket"
default['manifold']['manifold-api']['redis_sentinels'] = []
default['manifold']['manifold-api']['redis_namespace'] = 'manifold_production'
default['manifold']['manifold-api']['redis_db'] = 1
default['manifold']['manifold-api']['elasticsearch_host'] = "127.0.0.1"
default['manifold']['manifold-api']['elasticsearch_port'] = 3036

# Path to directory that contains (ca) certificates that should also be trusted (e.g. on
# outgoing Webhooks connections). For these certificates symlinks will be created in
# /opt/manifold/embedded/ssl/certs/.
default['manifold']['manifold-api']['trusted_certs_dir'] = "/etc/manifold/trusted-certs"

####
# API Puma
####
default['manifold']['puma']['enable'] = true
default['manifold']['puma']['log_directory'] = "/var/log/manifold/puma"
default['manifold']['puma']['dir'] = "#{node['package']['install-dir']}/var/puma"
default['manifold']['puma']['socket'] = '/var/opt/manifold/api/sockets/puma/api.sock'
default['manifold']['puma']['listen'] = '127.0.0.1'
default['manifold']['puma']['port'] = 3031
default['manifold']['puma']['pidfile'] = "#{node['package']['install-dir']}/var/puma/puma.pid"
default['manifold']['puma']['statefile'] = "#{node['package']['install-dir']}/var/puma/puma.state"
default['manifold']['puma']['rackup'] = "config.ru"
default['manifold']['puma']['worker_count'] = 1

####
# Cable
####
default['manifold']['cable']['enable'] = true
default['manifold']['cable']['log_directory'] = "/var/log/manifold/cable"
default['manifold']['cable']['dir'] = "#{node['package']['install-dir']}/var/cable"
default['manifold']['cable']['socket'] = '/var/opt/manifold/api/sockets/cable/cable.sock'
default['manifold']['cable']['listen'] = '127.0.0.1'
default['manifold']['cable']['port'] = 3032
default['manifold']['cable']['pidfile'] = "#{node['package']['install-dir']}/var/puma/cable.pid"
default['manifold']['cable']['statefile'] = "#{node['package']['install-dir']}/var/puma/cable.state"
default['manifold']['cable']['rackup'] = "cable/config.ru"
default['manifold']['cable']['worker_count'] = 1

####
# Clockwork
####
default['manifold']['clockwork']['enable'] = true
default['manifold']['clockwork']['log_directory'] = "/var/log/manifold/clockwork"

####
# Sidekiq
####
default['manifold']['sidekiq']['enable'] = true
default['manifold']['sidekiq']['ha'] = false
default['manifold']['sidekiq']['log_directory'] = "/var/log/manifold/sidekiq"
default['manifold']['sidekiq']['shutdown_timeout'] = 4
default['manifold']['sidekiq']['concurrency'] = 25

###
# PostgreSQL
###
default['manifold']['postgresql']['enable'] = true
default['manifold']['postgresql']['ha'] = false
default['manifold']['postgresql']['dir'] = "/var/opt/manifold/postgresql"
default['manifold']['postgresql']['data_dir'] = "/var/opt/manifold/postgresql/data"
default['manifold']['postgresql']['log_directory'] = "/var/log/manifold/postgresql"
default['manifold']['postgresql']['unix_socket_directory'] = "/var/opt/manifold/postgresql"
default['manifold']['postgresql']['username'] = "manifold-psql"
default['manifold']['postgresql']['uid'] = nil
default['manifold']['postgresql']['gid'] = nil
default['manifold']['postgresql']['shell'] = "/bin/sh"
default['manifold']['postgresql']['home'] = "/var/opt/manifold/postgresql"
# Postgres User's Environment Path
# defaults to /opt/manifold/embedded/bin:/opt/manifold/bin/$PATH. The install-dir path is set at build time
default['manifold']['postgresql']['user_path'] = "#{node['package']['install-dir']}/embedded/bin:#{node['package']['install-dir']}/bin:$PATH"
default['manifold']['postgresql']['sql_user'] = "manifold"
default['manifold']['postgresql']['sql_mattermost_user'] = "manifold_mattermost"
default['manifold']['postgresql']['port'] = 3034
# Postgres allow multi listen_address, comma-separated values.
# If used, first address from the list will be use for connection
default['manifold']['postgresql']['listen_address'] = "localhost"
default['manifold']['postgresql']['max_connections'] = 200
default['manifold']['postgresql']['md5_auth_cidr_addresses'] = []
default['manifold']['postgresql']['trust_auth_cidr_addresses'] = []
default['manifold']['postgresql']['shmmax'] = node['kernel']['machine'] =~ /x86_64/ ? 17179869184 : 4294967295
default['manifold']['postgresql']['shmall'] = node['kernel']['machine'] =~ /x86_64/ ? 4194304 : 1048575
default['manifold']['postgresql']['semmsl'] = 250
default['manifold']['postgresql']['semmns'] = 32000
default['manifold']['postgresql']['semopm'] = 32
default['manifold']['postgresql']['semmni'] = ((node['manifold']['postgresql']['max_connections'].to_i / 16) + 250)

# Resolves CHEF-3889
if (node['memory']['total'].to_i / 4) > ((node['manifold']['postgresql']['shmmax'].to_i / 1024) - 2097152)
  # guard against setting shared_buffers > shmmax on hosts with installed RAM > 64GB
  # use 2GB less than shmmax as the default for these large memory machines
  default['manifold']['postgresql']['shared_buffers'] = "14336MB"
else
  default['manifold']['postgresql']['shared_buffers'] = "#{(node['memory']['total'].to_i / 4) / (1024)}MB"
end

default['manifold']['postgresql']['work_mem'] = "8MB"
default['manifold']['postgresql']['maintenance_work_mem'] = "16MB"
default['manifold']['postgresql']['effective_cache_size'] = "#{(node['memory']['total'].to_i / 2) / (1024)}MB"
default['manifold']['postgresql']['log_min_duration_statement'] = -1 # Disable slow query logging by default
default['manifold']['postgresql']['checkpoint_segments'] = 10
default['manifold']['postgresql']['min_wal_size'] = '80MB'
default['manifold']['postgresql']['max_wal_size'] = '1GB'
default['manifold']['postgresql']['checkpoint_timeout'] = "5min"
default['manifold']['postgresql']['checkpoint_completion_target'] = 0.9
default['manifold']['postgresql']['checkpoint_warning'] = "30s"
default['manifold']['postgresql']['wal_buffers'] = "-1"
default['manifold']['postgresql']['autovacuum'] = "on"
default['manifold']['postgresql']['log_autovacuum_min_duration'] = "-1"
default['manifold']['postgresql']['autovacuum_max_workers'] = "3"
default['manifold']['postgresql']['autovacuum_naptime'] = "1min"
default['manifold']['postgresql']['autovacuum_vacuum_threshold'] = "50"
default['manifold']['postgresql']['autovacuum_analyze_threshold'] = "50"
default['manifold']['postgresql']['autovacuum_vacuum_scale_factor'] = "0.02" # 10x lower than PG defaults
default['manifold']['postgresql']['autovacuum_analyze_scale_factor'] = "0.01" # 10x lower than PG defaults
default['manifold']['postgresql']['autovacuum_freeze_max_age'] = "200000000"
default['manifold']['postgresql']['autovacuum_vacuum_cost_delay'] = "20ms"
default['manifold']['postgresql']['autovacuum_vacuum_cost_limit'] = "-1"
default['manifold']['postgresql']['statement_timeout'] = "0"
default['manifold']['postgresql']['log_line_prefix'] = nil
default['manifold']['postgresql']['track_activity_query_size'] = "1024"
default['manifold']['postgresql']['shared_preload_libraries'] = nil

# Replication settings
default['manifold']['postgresql']['sql_replication_user'] = "manifold_replicator"
default['manifold']['postgresql']['wal_level'] = "minimal"
default['manifold']['postgresql']['max_wal_senders'] = 0
default['manifold']['postgresql']['wal_keep_segments'] = 10
default['manifold']['postgresql']['hot_standby'] = "off"
default['manifold']['postgresql']['max_standby_archive_delay'] = "30s"
default['manifold']['postgresql']['max_standby_streaming_delay'] = "30s"

####
# Redis
####
default['manifold']['redis']['enable'] = true
default['manifold']['redis']['ha'] = false
default['manifold']['redis']['dir'] = "/var/opt/manifold/redis"
default['manifold']['redis']['log_directory'] = "/var/log/manifold/redis"
default['manifold']['redis']['username'] = "manifold-redis"
default['manifold']['redis']['uid'] = nil
default['manifold']['redis']['gid'] = nil
default['manifold']['redis']['shell'] = "/bin/false"
default['manifold']['redis']['home'] = "/var/opt/manifold/redis"
default['manifold']['redis']['bind'] = '127.0.0.1'
default['manifold']['redis']['port'] = 3035
default['manifold']['redis']['maxclients'] = "10000"
default['manifold']['redis']['tcp_timeout'] = 60
default['manifold']['redis']['tcp_keepalive'] = 300
default['manifold']['redis']['password'] = nil
default['manifold']['redis']['unixsocket'] = "/var/opt/manifold/redis/redis.socket"
default['manifold']['redis']['unixsocketperm'] = "777"
default['manifold']['redis']['master'] = true
default['manifold']['redis']['master_name'] = 'manifold-redis'
default['manifold']['redis']['master_ip'] = nil
default['manifold']['redis']['master_port'] = 3035
default['manifold']['redis']['master_password'] = nil
default['manifold']['redis']['client_output_buffer_limit_normal'] = "0 0 0"
default['manifold']['redis']['client_output_buffer_limit_slave'] = "256mb 64mb 60"
default['manifold']['redis']['client_output_buffer_limit_pubsub'] = "32mb 8mb 60"

####
# Web server
####
# Username for the webserver user
default['manifold']['web-server']['username'] = 'manifold-www'
default['manifold']['web-server']['group'] = 'manifold-www'
default['manifold']['web-server']['uid'] = nil
default['manifold']['web-server']['gid'] = nil
default['manifold']['web-server']['shell'] = '/bin/false'
default['manifold']['web-server']['home'] = '/var/opt/manifold/nginx'
# When bundled nginx is disabled we need to add the external webserver user to the Manifold webserver group
default['manifold']['web-server']['external_users'] = []

####
# Nginx
####
default['manifold']['nginx']['enable'] = true
default['manifold']['nginx']['ha'] = false
default['manifold']['nginx']['dir'] = "/var/opt/manifold/nginx"
default['manifold']['nginx']['log_directory'] = "/var/log/manifold/nginx"
default['manifold']['nginx']['worker_processes'] = node['cpu']['total'].to_i
default['manifold']['nginx']['worker_connections'] = 10240
default['manifold']['nginx']['log_format'] = '$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"' #  NGINX 'combined' format
default['manifold']['nginx']['sendfile'] = 'on'
default['manifold']['nginx']['tcp_nopush'] = 'on'
default['manifold']['nginx']['tcp_nodelay'] = 'on'
default['manifold']['nginx']['gzip'] = "on"
default['manifold']['nginx']['gzip_http_version'] = "1.0"
default['manifold']['nginx']['gzip_comp_level'] = "2"
default['manifold']['nginx']['gzip_proxied'] = "any"
default['manifold']['nginx']['gzip_types'] = [ "text/plain", "text/css", "application/x-javascript", "text/xml", "application/xml", "application/xml+rss", "text/javascript", "application/json" ]
default['manifold']['nginx']['keepalive_timeout'] = 65
default['manifold']['nginx']['client_max_body_size'] = '250m'
default['manifold']['nginx']['cache_max_size'] = '5000m'
default['manifold']['nginx']['redirect_http_to_https'] = false
default['manifold']['nginx']['ssl_client_certificate'] = nil # Most root CA's will be included by default
default['manifold']['nginx']['ssl_verify_client'] = nil # do not enable 2-way SSL client authentication
default['manifold']['nginx']['ssl_verify_depth'] = "1" # n/a if ssl_verify_client off
default['manifold']['nginx']['ssl_certificate'] = "/etc/manifold/ssl/#{node['fqdn']}.crt"
default['manifold']['nginx']['ssl_certificate_key'] = "/etc/manifold/ssl/#{node['fqdn']}.key"
default['manifold']['nginx']['ssl_trusted_certificate'] = nil
default['manifold']['nginx']['ssl_ciphers'] = "ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4"
default['manifold']['nginx']['ssl_prefer_server_ciphers'] = "on"
default['manifold']['nginx']['ssl_protocols'] = "TLSv1 TLSv1.1 TLSv1.2" # recommended by https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html & https://cipherli.st/
default['manifold']['nginx']['ssl_session_cache'] = "builtin:1000  shared:SSL:10m" # recommended in http://nginx.org/en/docs/http/ngx_http_ssl_module.html
default['manifold']['nginx']['ssl_session_timeout'] = "5m" # default according to http://nginx.org/en/docs/http/ngx_http_ssl_module.html
default['manifold']['nginx']['ssl_dhparam'] = nil # Path to dhparam.pem
default['manifold']['nginx']['listen_addresses'] = ['*']
default['manifold']['nginx']['listen_port'] = 80 # override only if you have a reverse proxy
default['manifold']['nginx']['listen_https'] = false
default['manifold']['nginx']['custom_manifold_server_config'] = nil
default['manifold']['nginx']['custom_nginx_config'] = nil
default['manifold']['nginx']['proxy_read_timeout'] = 3600
default['manifold']['nginx']['proxy_connect_timeout'] = 300
default['manifold']['nginx']['proxy_set_headers'] = {
  "Host" => "$http_host",
  "X-Real-IP" => "$remote_addr",
  "X-Forwarded-For" => "$proxy_add_x_forwarded_for",
  "Upgrade" => "$http_upgrade",
  "Connection" => "$connection_upgrade"
}
default['manifold']['nginx']['http2_enabled'] = true
# Cache up to 1GB of HTTP responses from Manifold on disk
default['manifold']['nginx']['proxy_cache_path'] = 'proxy_cache keys_zone=manifold:10m max_size=1g levels=1:2'
# Set to 'off' to disable proxy caching.
default['manifold']['nginx']['proxy_cache'] = 'manifold'
# Config for the http_realip_module http://nginx.org/en/docs/http/ngx_http_realip_module.html
default['manifold']['nginx']['real_ip_trusted_addresses'] = [] # Each entry creates a set_real_ip_from directive
default['manifold']['nginx']['real_ip_header'] = nil
default['manifold']['nginx']['real_ip_recursive'] = nil
default['manifold']['nginx']['server_names_hash_bucket_size'] = 64

###
# Nginx status
###
default['manifold']['nginx']['status']['enable'] = true
default['manifold']['nginx']['status']['listen_addresses'] = ['*']
default['manifold']['nginx']['status']['fqdn'] = "localhost"
default['manifold']['nginx']['status']['port'] = 3031
default['manifold']['nginx']['status']['options'] = {
  "stub_status" => "on",
  "server_tokens" => "off",
  "access_log" => "off",
  "allow" => "127.0.0.1",
  "deny" => "all",
}

###
# Logging
###
  default['manifold']['logging']['svlogd_size'] = 200 * 1024 * 1024 # rotate after 200 MB of log data
default['manifold']['logging']['svlogd_num'] = 30 # keep 30 rotated log files
default['manifold']['logging']['svlogd_timeout'] = 24 * 60 * 60 # rotate after 24 hours
default['manifold']['logging']['svlogd_filter'] = "gzip" # compress logs with gzip
default['manifold']['logging']['svlogd_udp'] = nil # transmit log messages via UDP
default['manifold']['logging']['svlogd_prefix'] = nil # custom prefix for log messages
default['manifold']['logging']['udp_log_shipping_host'] = nil # remote host to ship log messages to via UDP
default['manifold']['logging']['udp_log_shipping_port'] = 3032 # remote host to ship log messages to via UDP
default['manifold']['logging']['logrotate_frequency'] = "daily" # rotate logs daily
default['manifold']['logging']['logrotate_size'] = nil # do not rotate by size by default
default['manifold']['logging']['logrotate_rotate'] = 30 # keep 30 rotated logs
default['manifold']['logging']['logrotate_compress'] = "compress" # see 'man logrotate'
default['manifold']['logging']['logrotate_method'] = "copytruncate" # see 'man logrotate'
default['manifold']['logging']['logrotate_postrotate'] = nil # no postrotate command by default
default['manifold']['logging']['logrotate_dateformat'] = nil # use date extensions for rotated files rather than numbers e.g. a value of "-%Y-%m-%d" would give rotated files like production.log-2016-03-09.gz

###
# Logrotate
###
default['manifold']['logrotate']['enable'] = true
default['manifold']['logrotate']['ha'] = false
default['manifold']['logrotate']['dir'] = "/var/opt/manifold/logrotate"
default['manifold']['logrotate']['log_directory'] = "/var/log/manifold/logrotate"
default['manifold']['logrotate']['services'] = %w{manifold-api cable client clockwork nginx postgresql puma redis sidekiq}
default['manifold']['logrotate']['pre_sleep'] = 600 # sleep 10 minutes before rotating after start-up
default['manifold']['logrotate']['post_sleep'] = 3000 # wait 50 minutes after rotating

###
# Elasticsearch
###
default['manifold']['elasticsearch']['enable'] = true
default['manifold']['elasticsearch']['ha'] = false
default['manifold']['elasticsearch']['dir'] = "/var/opt/manifold/elasticsearch"
default['manifold']['elasticsearch']['data_dir'] = "/var/opt/manifold/elasticsearch/data"
default['manifold']['elasticsearch']['log_directory'] = "/var/log/manifold/elasticsearch"
default['manifold']['elasticsearch']['username'] = "manifold-elasticsearch"
default['manifold']['elasticsearch']['bind'] = '127.0.0.1'
default['manifold']['elasticsearch']['port'] = 3036
default['manifold']['elasticsearch']['uid'] = nil
default['manifold']['elasticsearch']['gid'] = nil
default['manifold']['elasticsearch']['shell'] = "/bin/sh"
default['manifold']['elasticsearch']['home'] = "/var/opt/manifold/elasticsearch"
