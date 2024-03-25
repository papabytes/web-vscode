#!/bin/bash

############################################
### installs ssmtp and registers crontab ###
############################################

setupSecretRotationNotifier() {
    installDir="/opt/secret-rotation-notifier"
    sudo apt update && sudo apt-get install ssmtp -y
    sudo mkdir -p $installDir
    sudo chown -R $USER $installDir        
    
    cd $installDir
    
    echo "Installing Secret Rotation Notifier Script"
    curl -o run.sh https://raw.githubusercontent.com/papabytes/web-vscode/main/secret-rotation-notifier.sh
    sed -i s/REPLACE_ME/$SMTP_AUTH_USER/g run.sh 
    chmod +x run.sh

    # Creating SSMTP configuration - using GMAIL as example you can select a different one.
    sudo echo "root=postmaster
hostname=$SMTP_MAIL_DOMAIN
UseTLS=YES
mailhub=$SMTP_SERVER:$SMTP_SERVER_PORT
AuthUser=$SMTP_AUTH_USER
AuthPass=$SMTP_AUTH_PASS
UseSTARTTLS=YES
FromLineOverride=YES" > /etc/ssmtp/ssmtp.conf

    # hourly run
    CRON_ENTRY="0 * * * * /opt/secret-rotation-notifier/run.sh 61"

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
    echo "Creating OpenVPN Installation Directory"
    createDir=$(sudo mkdir -p /opt/openvpn && sudo chown -R $USER /opt/openvpn/)
    cd /opt/openvpn

    echo "Downloading OpenVPN Install script to /opt/openvpn"
    download=$(sudo curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh && sudo chmod +x openvpn-install.sh)

    export AUTO_INSTALL=y

    echo "Installing OpenVPN"
    vpnInstallOut=$(sudo -E ./openvpn-install.sh)
}

setupVsCodeWeb() {
    sudo mkdir -p /opt/vscode-web 
    cd /opt/vscode-web

    echo "Downloading VsCode Web"
    downloadDockerfile=$(sudo curl -O https://raw.githubusercontent.com/papabytes/web-vscode/main/Dockerfile)
    composeFileNamePrefix="docker-compose"
    
    if [ "$SECURE_MODE" == "y" ]
    then
        composeFileNamePrefix="${composeFileNamePrefix}.secure.yaml"
    else
        composeFileNamePrefix="${composeFileNamePrefix}.unsecure.yaml"
    fi
    
    echo "Downloading Docker Compose File $composeFileNamePrefix"
    sudo curl -o docker-compose.yaml https://raw.githubusercontent.com/papabytes/web-vscode/main/$composeFileNamePrefix   
   
    sudo chown $USER -R /opt/vscode-web

    echo "Building Docker image"
    build=$(docker compose up -d --build)
}

echo "Installing VSCode Web"
if [[ "$SECURE_MODE"  == "y" ]]
then
    if [[ -z $SMTP_AUTH_USER ]]; then
        echo 'SMTP_AUTH_USER env var is required'
        exit 1
    fi

    if [[ -z $SMTP_AUTH_PASS ]]; then
        echo 'SMTP_AUTH_PASS env var is required'
        exit 1
    fi

    if [[ -z $SMTP_SERVER ]]; then
        echo 'SMTP_SERVER env var is required'
        exit 1
    fi

    if [[ -z $SMTP_SERVER_PORT ]]; then
        echo 'SMTP_SERVER_PORT env var is required'
        exit 1
    fi

    if [[ -z $SMTP_MAIL_DOMAIN ]]; then
        echo 'SMTP_MAIL_DOMAIN env var is required'
        exit 1
    fi

    echo 'Setting secret rotation notifier'
    setupSecretRotationNotifier
fi

if [[ "$VPN_MODE"  == "y" ]]
then
    setupOpenVPN
fi

setupVsCodeWeb
if [[ "$SECURE_MODE"  == "y" ]]
then
    echo sleeping for 10 seconds
    /opt/secret-rotation-notifier/run.sh 61
fi

echo "Finished."