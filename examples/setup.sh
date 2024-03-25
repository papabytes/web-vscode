#!/bin/bash

############################################
### installs ssmtp and registers crontab ###
############################################

setupSecretRotationNotifier() {
    apt update && apt-get install ssmtp -y
    mkdir -p /opt/secret-rotation-notifier
    chown -R $USER  /opt/secret-rotation-notifier

    # Creating SSMTP configuration - using GMAIL as example you can select a different one.
    echo '
    root=postmaster
    hostname=gmail.com
    UseTLS=YES
    mailhub=smtp.gmail.com:587
    AuthUser=REPLACE_ME
    AuthPass=REPLACE_ME
    UseSTARTTLS=YES
    FromLineOverride=YES
    ' > /etc/ssmtp/ssmtp.conf

    CRON_ENTRY="0 * * * * /opt/secret-rotation-notifier/run.sh"

    # Check if crontab entry exists
    if ! crontab -l | grep -q "$CRON_ENTRY"; then
        # Add crontab entry
        (crontab -l ; echo "$CRON_ENTRY") | crontab -
        echo "Crontab entry added successfully."
    else
        echo "Crontab entry already exists."
    fi
}

setupOpenVPN() {
    mkdir -p /opt/openvpn && chown -R $USER /opt/openvpn/
    cd /opt/openvpn
    curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
    chmod +x openvpn-install.sh
    export AUTO_INSTALL=y
    ./openvpn-install.sh
}

setupVsCodeWeb() {
    mkdir -p /opt/vscode-web
    sudo chown $USER -R /opt/vscode-web

    cd /opt/vscode-web
    curl -O https://raw.githubusercontent.com/papabytes/web-vscode/main/Dockerfile
    composeFileNamePrefix="docker-compose"
    
    if [ "$SECURE_MODE" == "y" ]
    then
        composeFileNamePrefix="${composeFileNamePrefix}.secure.yaml"
    else
        composeFileNamePrefix="${composeFileNamePrefix}.unsecure.yaml"
    fi
    
    curl -o docker-compose.yaml https://raw.githubusercontent.com/papabytes/web-vscode/main/examples/$composeFileNamePrefix
        
}

if [[ "$SECURE_MODE"  == "y" ]]
then
    echo 'Setting secret rotation notifier'
    setupSecretRotationNotifier
fi

if [[ "$VPN_MODE"  == "y" ]]
then

    setupOpenVPN
fi

setupVsCodeWeb