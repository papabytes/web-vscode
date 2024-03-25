#!/bin/bash

############################################
### installs ssmtp and registers crontab ###
############################################

setupSecretRotationNotifier() {
    installDir="/opt/secret-rotation-notifier"
    apt update && apt-get install ssmtp -y
    mkdir -p $installDir
    chown -R $USER $installDir

    cd $installDir
    curl -o run.sh https://raw.githubusercontent.com/papabytes/web-vscode/main/examples/secret-rotation-notifier.sh
    chmod +x run.sh

    # Creating SSMTP configuration - using GMAIL as example you can select a different one.
    echo "
    root=postmaster
    hostname=$SMTP_MAIL_DOMAIN
    UseTLS=YES
    mailhub=$SMTP_SERVER:$SMTP_SERVER_PORT
    AuthUser=$SMTP_AUTH_USER
    AuthPass=$SMTP_AUTH_PASS
    UseSTARTTLS=YES
    FromLineOverride=YES
    " > /etc/ssmtp/ssmtp.conf

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
    mkdir -p /opt/openvpn && chown -R $USER /opt/openvpn/
    cd /opt/openvpn
    curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
    chmod +x openvpn-install.sh
    export AUTO_INSTALL=y
    ./openvpn-install.sh
}

setupVsCodeWeb() {
    mkdir -p /opt/vscode-web
    chown $USER -R /opt/vscode-web

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
    
    docker compose up -d
}


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