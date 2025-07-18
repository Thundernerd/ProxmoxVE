#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: Slaviša Arežina (tremor021)
# License: MIT | https://github.com/Thundernerd/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/Snd-R/komf

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

JAVA_VERSION=21 setup_java

fetch_and_deploy_gh_release "Komf" "Snd-R/komf" "singlefile" "latest" "/opt/komf" "komf-*.jar"

msg_info "Creating configuration stub"
touch /opt/komf/application.yml
msg_ok "Created configuration stub"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/komf.service
[Unit]
Description=Komf Service
After=network.target

[Service]
User=root
Type=simple
ExecStart=/usr/bin/java -jar /opt/komf/Komf /opt/komf
TimeoutStopSec=20
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now komf
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
