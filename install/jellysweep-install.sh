#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: Thundernerd
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/jon4hz/jellysweep

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Jellysweep"

fetch_and_deploy_gh_release "Jellysweep" "jon4hz/jellysweep" "binary"

mkdir -p /etc/jellysweep/
cat <<EOF >/etc/jellysweep/jellysweep.conf
dry_run: false                   # Set to true for testing
listen: "0.0.0.0:3002"           # Web interface address and port
cleanup_schedule: "0 */12 * * *" # Every 12 hours
cleanup_mode: "keep_seasons"     # Cleanup mode: "all", "keep_episodes", or "keep_seasons"
keep_count: 1                    # Number of episodes/seasons to keep (when using keep_episodes or keep_seasons)
session_key: "your-session-key"  # Random string for session encryption
session_max_age: 172800          # Session max age in seconds (48 hours)
server_url: "http://localhost:3002"

# Cache configuration (optional)
cache:
  type: "memory"                 # Cache type: "memory" or "redis"
  redis_url: "localhost:6379"    # Redis server URL (when using redis cache)

# Authentication (optional - if no auth is configured, web interface is accessible without authentication)
# Warning: No authentication is only recommended for development environments
auth:
  # OpenID Connect (OIDC) Authentication
  oidc:
    enabled: false
    name: OIDC
    issuer: "https://login.mydomain.com/application/o/jellysweep/"
    client_id: "your-client-id"
    client_secret: "your-client-secret"
    redirect_url: "http://localhost:3002/auth/oidc/callback"
    admin_group: "jellyfin-admins"     # OIDC group for admin access

  # Jellyfin Authentication
  jellyfin:
    enabled: true                      # Default authentication method

# Jellyfin server configuration
jellyfin:
  url: "http://localhost:8096"         # Your Jellyfin server URL
  api_key: "your-jellyfin-api-key"     # Jellyfin API key

# Profile Pictures (optional)
gravatar:
  enabled: false                       # Enable Gravatar profile pictures
  default_image: "mp"                  # Default image if no Gravatar found
                                       # Options: "404", "mp", "identicon", "monsterid",
                                       #          "wavatar", "retro", "robohash", "blank"
  rating: "g"                          # Maximum rating for images
                                       # Options: "g", "pg", "r", "x"
  size: 80                             # Image size in pixels (1-2048)

# Library-specific settings
libraries:

  "Movies":
    enabled: true
    content_age_threshold: 120
    last_stream_threshold: 90
    content_size_threshold: 1073741824  # 1GB minimum
    cleanup_delay: 60
    exclude_tags:
      - "jellysweep-exclude"
      - "keep"
      - "favorites"
    # Disk usage-based cleanup for movies
    disk_usage_thresholds:
      - usage_percent: 70.0       # When disk usage reaches 70%
        max_cleanup_delay: 30     # Reduce grace period to 30 days
      - usage_percent: 85.0       # When disk usage reaches 85%
        max_cleanup_delay: 14      # Reduce grace period to 14 days
      - usage_percent: 90.0       # When disk usage reaches 90%
        max_cleanup_delay: 7      # Reduce grace period to 7 days
      - usage_percent: 95.0       # When disk usage reaches 95%
        max_cleanup_delay: 2      # Reduce grace period to 2 days

  "TV Shows":
    enabled: true
    content_age_threshold: 120
    last_stream_threshold: 90
    content_size_threshold: 2147483648  # 2GB minimum
    cleanup_delay: 60
    exclude_tags:
      - "jellysweep-exclude"
      - "ongoing"
      - "keep"
    # Disk usage-based cleanup for TV shows
    disk_usage_thresholds:
      - usage_percent: 70.0
        max_cleanup_delay: 30
      - usage_percent: 85.0
        max_cleanup_delay: 14
      - usage_percent: 90.0
        max_cleanup_delay: 7
      - usage_percent: 95.0
        max_cleanup_delay: 2

# Email notifications for users about upcoming deletions
email:
  enabled: false
  smtp_host: "mail.example.com"
  smtp_port: 587
  username: "your-smtp-username"
  password: "your-smtp-password"
  from_email: "jellysweep@example.com"
  from_name: "Jellysweep"
  use_tls: true              # Use STARTTLS
  use_ssl: false             # Use implicit SSL/TLS
  insecure_skip_verify: false

# Ntfy notifications for admins about keep requests and deletions
ntfy:
  enabled: false
  server_url: "https://ntfy.sh"  # Or your own ntfy server
  topic: "jellysweep"
  # Authentication options (choose one):
  username: ""               # Username/password auth
  password: ""
  token: ""                  # Token auth (takes precedence)

# Web push notifications
webpush:
  enabled: false
  vapid_email: "your-email@example.com"  # Contact email for VAPID keys
  public_key: ""                         # VAPID public key (generate with: ./jellysweep generate-vapid-keys)
  private_key: ""                        # VAPID private key

# External service integrations
jellyseerr:
  url: "http://localhost:5055"
  api_key: "your-jellyseerr-api-key"

sonarr:
  url: "http://localhost:8989"
  api_key: "your-sonarr-api-key"

radarr:
  url: "http://localhost:7878"
  api_key: "your-radarr-api-key"

jellystat:
  url: "http://localhost:3001"
  api_key: "your-jellystat-api-key"

# Alternative to Jellystat (configure only one)
streamystats:
  url: "http://localhost:3001"
  server_id: 1                         # Jellyfin server ID in Streamystats

# Cache configuration (optional - improves performance for large libraries)
cache:
  enabled: true                  # Enable caching system
  type: "memory"                 # Options: "memory", "redis"
  redis_url: "localhost:6379"    # Redis server URL (when using redis cache)
EOF

msg_ok "Installed Jellysweep"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/jellysweep.service
[Unit]
Description=Jellysweep Service
After=network.target

[Service]
ExecStart=/usr/bin/jellysweep --config /etc/jellysweep/jellysweep.conf
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now jellysweep
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
