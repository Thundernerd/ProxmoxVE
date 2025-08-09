#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/Thundernerd/ProxmoxVE/jellysweep/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: Thundernerd
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/jon4hz/jellysweep

APP="Jellysweep"
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

  if [[ ! -f /usr/bin/jellysweep ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  msg_info "Stopping $APP"
  systemctl stop jellysweep
  msg_ok "Stopped $APP"

  fetch_and_deploy_gh_release "Jellysweep" "jon4hz/jellysweep" "binary"

  msg_info "Starting $APP"
  systemctl start jellysweep
  msg_ok "Started $APP"

  msg_ok "Update Successful"
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:3002${CL}"
