#!/bin/bash

set -e

# These 3 variables constant for all development projects
BACKEND_RESOURCE_GROUP_NAME=terraform-state-rg
BACKEND_STORAGE_CONTAINER_NAME=tfstate
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
FUNCTION_NAME=visit_counter

if [ -z $GITHUB_ACTIONS ]; then
    RESOURCE_GROUP_NAME="dev-$(date +%Y%m%d%H%M)-rg"
else
    RESOURCE_GROUP_NAME="test-$(date +%Y%m%d%H%M)-rg"
fi

echo "Creating resource group if it does not exist"
if ! az group exists --name "$BACKEND_RESOURCE_GROUP_NAME"; then
    az group create --name $BACKEND_RESOURCE_GROUP_NAME --location eastus2
else
    echo "Resource group $BACKEND_RESOURCE_GROUP_NAME already exists."
fi

echo "Creating backend storage account"
while true; do
    # Generate a new storage account name
    BACKEND_STORAGE_ACCOUNT_NAME="devtfstate$RANDOM"

    # Check if the storage account name already exists
    account_check=$(az storage account check-name --name $BACKEND_STORAGE_ACCOUNT_NAME --query 'nameAvailable')

    # If the name is available, break out of the loop
    if [ $account_check = "true" ]; then
        break
    fi
done

az storage account create \
    --resource-group $BACKEND_RESOURCE_GROUP_NAME \
    --name $BACKEND_STORAGE_ACCOUNT_NAME \
    --sku Standard_LRS

az storage container create \
    --name $BACKEND_STORAGE_CONTAINER_NAME \
    --account-name $BACKEND_STORAGE_ACCOUNT_NAME

echo "Initiating terraform backend"

cd terraform

terraform init \
    -backend-config="resource_group_name=$BACKEND_RESOURCE_GROUP_NAME" \
    -backend-config="storage_account_name=$BACKEND_STORAGE_ACCOUNT_NAME" \
    -backend-config="container_name=$BACKEND_STORAGE_CONTAINER_NAME"

echo "Creating terraform plan"
terraform plan \
    -var "rg_name=$RESOURCE_GROUP_NAME" \
    -var "subscription_id=$AZURE_SUBSCRIPTION_ID" \
    -out=tfplan

echo "Applying the terraform plan"
terraform apply -auto-approve tfplan

RESOURCE_GROUP_NAME=$(terraform output -raw resource_group_name)
COSMOSDB_CONNECTION_STRING=$(terraform output -raw cosmosdb_connection_string)
FUNCTION_APP_NAME=$(terraform output -raw function_app_name)
FUNCTION_APP_URL=$(terraform output -raw function_app_url)
STATIC_STORAGE_ACCOUNT_NAME=$(terraform output -raw static_website_storage_name)

echo "Function Setup"

cd ..

echo "Packaging function"
cd backend/api
zip -r ../../function.zip * -x "local.settings.json" ".venv/*" "visit_counter/__pycache__/*"
cd ../..

echo "Deploying function"
az functionapp deployment source config-zip \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $FUNCTION_APP_NAME \
    --src function.zip

sleep 90

echo "Getting function key"
FUNCTION_KEY=$(
    az functionapp function keys list \
        --name $FUNCTION_APP_NAME \
        --resource-group $RESOURCE_GROUP_NAME \
        --function-name $FUNCTION_NAME \
        --query "default" -o tsv
)

echo "Adding function url to visitcounter.js"
FUNCTION_URL="https://${FUNCTION_APP_URL}/api/visit_counter?code=${FUNCTION_KEY}"

# Replace TODO with the function url
#using -i.bak is a hack to enable sed to work on both mac and linux OS
sed -i.bak "s|TODO|$FUNCTION_URL|" ./frontend/js/visitcounter.js

echo "Uploading frontend contents"
az storage blob upload-batch \
    --account-name $STATIC_STORAGE_ACCOUNT_NAME \
    --auth-mode key \
    --overwrite=true \
    --destination '$web' \
    --source frontend/

ENDPOINT_HOSTNAME="https://${STATIC_STORAGE_ACCOUNT_NAME}.azureedge.net"

echo "Enabling CORS"
az functionapp cors remove --name $FUNCTION_APP_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --allowed-origins

az functionapp cors add --name $FUNCTION_APP_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --allowed-origins "*"

variables=(
    "BACKEND_RESOURCE_GROUP_NAME"
    "BACKEND_STORAGE_ACCOUNT_NAME"
    "RESOURCE_GROUP_NAME"
    "ENDPOINT_HOSTNAME"
    "FUNCTION_URL"
)

if [ -z $GITHUB_ACTIONS ]; then
    file_name="dev.env"
else
    file_name="test.env"
fi

for var in "${variables[@]}"; do
    echo "${var}=${!var}" >>$file_name
done
