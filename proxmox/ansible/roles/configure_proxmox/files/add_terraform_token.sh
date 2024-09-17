#!/bin/bash

source /tmp/common.sh

# Vérifier si le token existe déjà
pveum user token list "$TERRAFORM_UGID" -o json | jq -e --arg token "$TOKEN_NAME" '.[] | select(.tokenid == $token)' > /dev/null

if [ $? -eq 0 ]; then
    echo "Token '$TOKEN_NAME' already exists for user '$TERRAFORM_UGID'. No action taken."
else
    echo "Creating token '$TOKEN_NAME' for user '$TERRAFORM_UGID'."
    # Créer le token
    run_command "pveum user token add $TERRAFORM_UGID $TOKEN_NAME -expire $TOKEN_EXPIRE -privsep $TOKEN_PRIVSEP -comment \"$TOKEN_COMMENT\" -o json > /root/.terraform_token"
fi
