#!/bin/bash

############################################
### installs ssmtp and registers crontab ###
############################################
sudo apt update && sudo apt-get install ssmtp -y
sudo mkdir -p /opt/secret-rotation-notifier
sudo chown -R $USER  /opt/secret-rotation-notifier

# Creating SSMTP configuration - using GMAIL as example you can select a different one.
sudo echo '
root=postmaster
hostname=gmail.com
UseTLS=YES
mailhub=smtp.gmail.com:587
AuthUser=REPLACE_ME
AuthPass=REPLACE_ME
UseSTARTTLS=YES
FromLineOverride=YES
' > /etc/ssmtp/ssmtp.conf

CRON_ENTRY="*/5 * * * * /opt/secret-rotation-notifier/run.sh"

# Check if crontab entry exists
if ! crontab -l | grep -q "$CRON_ENTRY"; then
    # Add crontab entry
    (crontab -l ; echo "$CRON_ENTRY") | crontab -
    echo "Crontab entry added successfully."
else
    echo "Crontab entry already exists."
fi