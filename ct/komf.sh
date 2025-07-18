#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/Thundernerd/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: Slaviša Arežina (tremor021)
# License: MIT | https://github.com/Thundernerd/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/Snd-R/komf

APP="Komf"
var_tags="${var_tags:-media;manga}"
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

  msg_info "Updating $APP"

  msg_info "Stopping $APP"
  systemctl stop komf
  msg_ok "Stopped $APP"

  msg_info "Updating $APP"
  fetch_and_deploy_gh_release "Komf" "Snd-R/komf" "singlefile" "latest" "/opt/komf" "komf-*.jar"
  msg_ok "Updated $APP"

  msg_info "Starting $APP"
  systemctl start komf
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
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8085${CL}"
