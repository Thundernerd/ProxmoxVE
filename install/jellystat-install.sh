#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: Thundernerd
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/CyferShepard/Jellystat

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y \
    git \
    build-essential
setup_nodejs
setup_postgres
msg_ok "Installed Dependencies"

git clone -q https://github.com/CyferShepard/Jellystat.git /opt/jellystat
cd /opt/jellystat
$STD git checkout main

msg_info "Installing Jellystat"
cd /opt/jellystat
npm install
chmod +x ./entry.sh
sed -i -e 's/\r$//' entry.sh

mkdir -p /etc/jellystat/
cat <<EOF >/etc/jellystat/jellystat.conf
POSTGRES_USER=postgres
POSTGRES_PASSWORD=password
POSTGRES_IP=127.0.0.1
POSTGRES_PORT=5432
JWT_SECRET=$(openssl rand -base64 32)
TZ=Etc/UTC
EOF

msg_ok "Installed Jellystat"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/jellystat.service
[Unit]
Description=Jellystat Service
After=network.target

[Service]
EnvironmentFile=/etc/jellystat/jellystat.conf
ExecStart=/opt/jellystat/entry.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now jellystat
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
