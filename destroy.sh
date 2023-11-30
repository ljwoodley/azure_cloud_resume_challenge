#!/bin/bash

set -e

if [ -z $GITHUB_ACTIONS ]; then
    # Sourcing environment variables for dev setup
    source dev.env
fi

echo "Deleting Azure resources"
az group delete --name $RESOURCE_GROUP_NAME --yes --no-wait

echo "Deleting terraform backend storage account"
az storage account delete \
    --resource-group $BACKEND_RESOURCE_GROUP_NAME \
    --name $BACKEND_STORAGE_ACCOUNT_NAME \
    --yes

if [ -z $GITHUB_ACTIONS ]; then
    # echo "Deleting dev files"
    rm dev.env function.zip ./frontend/js/visitcounter.js.bak ./backend/api/local.settings.json.bak

    # echo "Deleting dev terraform states and plan"
    rm -rf ./terraform/.terraform ./terraform/.terraform.lock.hcl ./terraform/tfplan
fi
