#!/bin/bash
#
MINUTES=$1

if [[ -z $MINUTES ]]
then
    MINUTES=5
fi

getToken() {
    minutes=$1
    token="$(docker logs vscode_web --since ${minutes}m 2>&1 | grep -Eo "tkn=.*" | sed s/tkn=//g)"
    
    if [ $token != "" ]
    then
        echo $token
    else
        echo "token is empty. exitting"
        exit 1
    fi
}

# Send email
send_email() {
    echo "sending email"
    token=$1
    SUBJECT="VSCode web token"

    echo "Subject: VSCode Web token

    New token is: $token
    " > mail.txt
    mailSend=$(/usr/sbin/ssmtp -v REPLACE_ME < mail.txt)
    echo "email sent"
}

token=$(getToken $MINUTES)
send_email $token




