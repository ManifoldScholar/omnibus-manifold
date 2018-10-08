## Manifold configuration settings
##! This file is generated during initial installation and **is not** modified
##! during upgrades.


## Manifold URL
##! URL on which Manifold will be reachable.
##! For more details on configuring external_url see:
external_url 'GENERATED_EXTERNAL_URL'

## Legend
##! The following notations at the beginning of each line may be used to
##! differentiate between components of this file and to easily select them using
##! a regex.
##! ## Titles, subtitles etc
##! ##! More information - Description, Docs, Links, Issues etc.
##! Configuration settings have a single # followed by a single space at the
##! beginning; Remove them to enable the setting.

##! **Configuration settings below are optional.**
##! **The values currently assigned are only examples and ARE NOT the default
##!   values.**


################################################################################
################################################################################
##                Configuration Settings for Manifold                         ##
################################################################################
################################################################################

################################################################################
## settings.yml configuration
################################################################################

### Trusted proxies
###! Customize if you have Manifold behind a reverse proxy which is running on a
###! different machine.
###! **Add the IP address for your reverse proxy to the list, otherwise users
###!   will appear signed in from that address.**
# manifold_api['trusted_proxies'] = []

###! **We do not recommend changing these directories.**
# manifold_api['dir'] = "/var/opt/manifold/manifold-rails"
# manifold_api['log_directory'] = "/var/log/manifold/manifold-rails"

### Manifold application settings
# manifold_api['uploads_directory'] = "/var/opt/manifold/manifold-rails/uploads"
# manifold_api['rate_limit_requests_per_period'] = 10
# manifold_api['rate_limit_period'] = 60

#### Enable or disable automatic database migrations
# manifold_api['auto_migrate'] = true

#### Add custom environment to Manifold API
# manifold_api['env'] = {
#   FOO => "bar"
# }

### Manifold database settings
###! **Only needed if you use an external database.**
# manifold_api['db_adapter'] = "postgresql"
# manifold_api['db_encoding'] = "unicode"
# manifold_api['db_collation'] = nil
# manifold_api['db_database'] = "manifold_production"
# manifold_api['db_pool'] = 10
# manifold_api['db_username'] = "manifold"
# manifold_api['db_password'] = nil
# manifold_api['db_host'] = nil
# manifold_api['db_port'] = 5432
# manifold_api['db_socket'] = nil
# manifold_api['db_sslmode'] = nil
# manifold_api['db_sslrootcert'] = nil

### Manifold Redis settings
###! Connect to your own Redis instance

#### Redis TCP connection
# manifold_api['redis_host'] = "127.0.0.1"
# manifold_api['redis_port'] = 6379
# manifold_api['redis_password'] = nil
# manifold_api['redis_database'] = 0

#### Redis local UNIX socket (will be disabled if TCP method is used)
# manifold_api['redis_socket'] = "/var/opt/manifold/redis/redis.socket"

################################################################################
## Manifold User Settings
################################################################################

# user['username'] = "manifold"
# user['group'] = "manifold"
# user['uid'] = nil
# user['gid'] = nil

##! The shell for the main user
# user['shell'] = "/bin/sh"

##! The home directory for the main user
# user['home'] = "/var/opt/manifold"

################################################################################
## Manifold Sidekiq
################################################################################

# sidekiq['log_directory'] = "/var/log/manifold/sidekiq"
# sidekiq['shutdown_timeout'] = 4
# sidekiq['concurrency'] = 25

################################################################
## Manifold PostgreSQL
################################################################

# postgresql['enable'] = true
# postgresql['listen_address'] = nil
# postgresql['port'] = 5432
# postgresql['data_dir'] = "/var/opt/manifold/postgresql/data"

##! **recommend value is 1/4 of total RAM, up to 14GB.**
# postgresql['shared_buffers'] = "256MB"

### Advanced settings
# postgresql['dir'] = "/var/opt/manifold/postgresql"
# postgresql['log_directory'] = "/var/log/manifold/postgresql"
# postgresql['username'] = "manifold-psql"
# postgresql['uid'] = nil
# postgresql['gid'] = nil
# postgresql['shell'] = "/bin/sh"
# postgresql['home'] = "/var/opt/manifold/postgresql"
# postgresql['user_path'] = "/opt/manifold/embedded/bin:/opt/manifold/bin:$PATH"
# postgresql['sql_user'] = "manifold"
# postgresql['max_connections'] = 200
# postgresql['md5_auth_cidr_addresses'] = []
# postgresql['trust_auth_cidr_addresses'] = []
# postgresql['shmmax'] =  17179869184 # or 4294967295
# postgresql['shmall'] =  4194304 # or 1048575
# postgresql['work_mem'] = "8MB"
# postgresql['maintenance_work_mem'] = "16MB"
# postgresql['effective_cache_size'] = "1MB"
# postgresql['checkpoint_segments'] = 10
# postgresql['checkpoint_timeout'] = "5min"
# postgresql['checkpoint_completion_target'] = 0.9
# postgresql['checkpoint_warning'] = "30s"
# postgresql['wal_buffers'] = "-1"
# postgresql['autovacuum'] = "on"
# postgresql['log_autovacuum_min_duration'] = "-1"
# postgresql['autovacuum_max_workers'] = "3"
# postgresql['autovacuum_naptime'] = "1min"
# postgresql['autovacuum_vacuum_threshold'] = "50"
# postgresql['autovacuum_analyze_threshold'] = "50"
# postgresql['autovacuum_vacuum_scale_factor'] = "0.02"
# postgresql['autovacuum_analyze_scale_factor'] = "0.01"
# postgresql['autovacuum_freeze_max_age'] = "200000000"
# postgresql['autovacuum_vacuum_cost_delay'] = "20ms"
# postgresql['autovacuum_vacuum_cost_limit'] = "-1"
# postgresql['statement_timeout'] = "0"
# postgresql['log_line_prefix'] = "%a"
# postgresql['track_activity_query_size'] = "1024"
# postgresql['shared_preload_libraries'] = nil

### Replication settings
# postgresql['sql_replication_user'] = "manifold_replicator"
# postgresql['wal_level'] = "hot_standby"
# postgresql['max_wal_senders'] = 5
# postgresql['wal_keep_segments'] = 10
# postgresql['hot_standby'] = "off"
# postgresql['max_standby_archive_delay'] = "30s"
# postgresql['max_standby_streaming_delay'] = "30s"

### Available in PostgreSQL 9.6 and later
# postgresql['min_wal_size'] = 80MB
# postgresql['max_wal_size'] = 1GB

################################################################################
## Manifold Redis
##! **Can be disabled if you are using your own Redis instance.**
################################################################################

# redis['enable'] = true
# redis['username'] = "manifold-redis"
# redis['maxclients'] = "10000"
# redis['tcp_timeout'] = "60"
# redis['tcp_keepalive'] = "300"
# redis['uid'] = nil
# redis['gid'] = nil

### Redis TCP support (will disable UNIX socket transport)
# redis['bind'] = '0.0.0.0' # or specify an IP to bind to a single one
# redis['port'] = 6379
# redis['password'] = 'redis-password-goes-here'

################################################################################
## Manifold Web server
################################################################################

##! When bundled nginx is disabled we need to add the external webserver user to
##! the Manifold webserver group.
# web_server['external_users'] = []
# web_server['username'] = 'manifold-www'
# web_server['group'] = 'manifold-www'
# web_server['uid'] = nil
# web_server['gid'] = nil
# web_server['shell'] = '/bin/false'
# web_server['home'] = '/var/opt/manifold/nginx'

################################################################################
## Manifold Nginx
################################################################################

# nginx['enable'] = true
# nginx['client_max_body_size'] = '250m'
# nginx['redirect_http_to_https'] = false

##! Most root CA's are included by default
# nginx['ssl_client_certificate'] = "/etc/manifold/ssl/ca.crt"

##! enable/disable 2-way SSL client authentication
# nginx['ssl_verify_client'] = "off"

##! if ssl_verify_client on, verification depth in the client certificates chain
# nginx['ssl_verify_depth'] = "1"

# nginx['ssl_certificate'] = "/etc/manifold/ssl/#{node['fqdn']}.crt"
# nginx['ssl_certificate_key'] = "/etc/manifold/ssl/#{node['fqdn']}.key"
# nginx['ssl_ciphers'] = "ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256"
# nginx['ssl_prefer_server_ciphers'] = "on"

##! **Recommended by: https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html
##!                   https://cipherli.st/**
# nginx['ssl_protocols'] = "TLSv1 TLSv1.1 TLSv1.2"

##! **Recommended in: https://nginx.org/en/docs/http/ngx_http_ssl_module.html**
# nginx['ssl_session_cache'] = "builtin:1000  shared:SSL:10m"

##! **Default according to https://nginx.org/en/docs/http/ngx_http_ssl_module.html**
# nginx['ssl_session_timeout'] = "5m"

# nginx['ssl_dhparam'] = nil # Path to dhparams.pem, eg. /etc/manifold/ssl/dhparams.pem
# nginx['listen_addresses'] = ['*', '[::]']

##! **Override only if you use a reverse proxy**
# nginx['listen_port'] = nil

##! **Only enable if you've also setup SSL certificate and key**
# nginx['listen_https'] = false

# nginx['custom_manifold_server_config'] = "location ^~ /foo-namespace/bar-project/raw/ {\n deny all;\n}\n"
# nginx['custom_nginx_config'] = "include /etc/nginx/conf.d/example.conf;"
# nginx['proxy_read_timeout'] = 3600
# nginx['proxy_connect_timeout'] = 300

# nginx['proxy_cache_path'] = 'proxy_cache keys_zone=manifold:10m max_size=1g levels=1:2'
# nginx['proxy_cache'] = 'manifold'
# nginx['http2_enabled'] = true
# nginx['real_ip_trusted_addresses'] = []
# nginx['real_ip_header'] = nil
# nginx['real_ip_recursive'] = nil
# nginx['custom_error_pages'] = {
#   '404' => {
#     'title' => 'Example title',
#     'header' => 'Example header',
#     'message' => 'Example message'
#   }
# }

### Advanced settings
# nginx['dir'] = "/var/opt/manifold/nginx"
# nginx['log_directory'] = "/var/log/manifold/nginx"
# nginx['worker_processes'] = 4
# nginx['worker_connections'] = 10240
# nginx['log_format'] = '$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"'
# nginx['sendfile'] = 'on'
# nginx['tcp_nopush'] = 'on'
# nginx['tcp_nodelay'] = 'on'
# nginx['gzip'] = "on"
# nginx['gzip_http_version'] = "1.0"
# nginx['gzip_comp_level'] = "2"
# nginx['gzip_proxied'] = "any"
# nginx['gzip_types'] = [ "text/plain", "text/css", "application/x-javascript", "text/xml", "application/xml", "application/xml+rss", "text/javascript", "application/json" ]
# nginx['keepalive_timeout'] = 65
# nginx['cache_max_size'] = '5000m'
# nginx['server_names_hash_bucket_size'] = 64

### Nginx status
# nginx['status'] = {
#  "enable" => true,
#  "listen_addresses" => ["127.0.0.1"],
#  "fqdn" => "dev.example.com",
#  "port" => 9999,
#  "options" => {
#    "stub_status" => "on", # Turn on stats
#    "server_tokens" => "off", # Don't show the version of NGINX
#    "access_log" => "on", # Disable logs for stats
#    "allow" => "127.0.0.1", # Only allow access from localhost
#    "deny" => "all" # Deny access to anyone else
#  }
# }

################################################################################
## Manifold Logging
################################################################################

# logging['svlogd_size'] = 200 * 1024 * 1024 # rotate after 200 MB of log data
# logging['svlogd_num'] = 30 # keep 30 rotated log files
# logging['svlogd_timeout'] = 24 * 60 * 60 # rotate after 24 hours
# logging['svlogd_filter'] = "gzip" # compress logs with gzip
# logging['svlogd_udp'] = nil # transmit log messages via UDP
# logging['svlogd_prefix'] = nil # custom prefix for log messages
# logging['logrotate_frequency'] = "daily" # rotate logs daily
# logging['logrotate_size'] = nil # do not rotate by size by default
# logging['logrotate_rotate'] = 30 # keep 30 rotated logs
# logging['logrotate_compress'] = "compress" # see 'man logrotate'
# logging['logrotate_method'] = "copytruncate" # see 'man logrotate'
# logging['logrotate_postrotate'] = nil # no postrotate command by default
# logging['logrotate_dateformat'] = nil # use date extensions for rotated files rather than numbers e.g. a value of "-%Y-%m-%d" would give rotated files like production.log-2016-03-09.gz

################################################################################
## Logrotate
##! You can disable built in logrotate feature.
################################################################################

# logrotate['enable'] = true

################################################################################
## Users and groups accounts
##! Disable management of users and groups accounts.
##! **Set only if creating accounts manually**
################################################################################

# manage_accounts['enable'] = false

################################################################################
## Storage directories
##! Disable managing storage directories
################################################################################

##! **Set only if the select directories are created manually**
# manage_storage_directories['enable'] = false
# manage_storage_directories['manage_etc'] = false
