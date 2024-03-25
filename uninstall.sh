#!/bin/bash
echo "Removing secret rotation notifier"
sudo rm -rf /opt/secret-rotation-notifier

echo "Removing VSCode Web"
sudo rm -rf /opt/vscode-web
docker rm -f vscode_web

echo "Uninstalling OpenVPN - select option 3"
unset AUTO_INSTALL
cd /opt/openvpn && sudo -E ./openvpn-install.sh