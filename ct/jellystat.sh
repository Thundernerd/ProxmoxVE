#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/Thundernerd/ProxmoxVE/jellystat/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: Thundernerd
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/CyferShepard/Jellystat

APP="Jellystat"
var_tags="${var_tags:-media}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-12}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d /opt/jellystat ]]; then
      msg_error "No ${APP} Installation Found!"
      exit
  fi

  cd /opt/jellystat
  output=$(git pull --no-rebase)

  msg_info "Updating $APP"
  if echo "$output" | grep -q "Already up to date."; then
      msg_ok "$APP is already up to date."
      exit
  fi

  systemctl stop jellyseerr
  rm -rf dist .next node_modules
  cd /opt/jellyseerr
  $STD npm install

  systemctl start jellyseerr
  msg_ok "Updated $APP"
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:4567${CL}"
