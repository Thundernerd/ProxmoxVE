#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: Slaviša Arežina (tremor021)
# License: MIT | https://github.com/Thundernerd/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/Suwayomi/Suwayomi-Server-preview

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y libc++-dev
msg_ok "Installed Dependencies"

JAVA_VERSION=21 setup_java

msg_info "Settting up Suwayomi-server"
temp_file=$(mktemp)
RELEASE=$(curl -fsSL https://api.github.com/repos/Suwayomi/Suwayomi-Server-preview/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
curl -fsSL "https://github.com/Suwayomi/Suwayomi-Server-preview/releases/download/${RELEASE}/Suwayomi-Server-${RELEASE}-debian-all.deb" -o "$temp_file"
$STD dpkg -i "$temp_file"
echo "${RELEASE}" >/opt/Suwayomi-server_version.txt
msg_ok "Done setting up Suwayomi-server"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/Suwayomi-server.service
[Unit]
Description=Suwayomi-server Service
After=network.target

[Service]
ExecStart=/usr/bin/Suwayomi-server
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now Suwayomi-server
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
rm -f "$temp_file"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
