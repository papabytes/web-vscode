#!/bin/bash
getToken() {
    token="$(docker logs vscode_web 2>&1 | grep -Eo "tkn=.*" | sed s/tkn=//g)"
    echo "$token"
}

# Send email
send_email() {
    token=$1
    echo "New Token is $token" | /usr/bin/mailx -s "VS Code Web Token" j.alex.abrantes
}

token=$(getToken)
if [ "$token" != "" ]; then
  send_email "$token"
fi