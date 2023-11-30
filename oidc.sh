#!/bin/bash
set -eu

APP_NAME=$1
SUBSCRIPTION=$2
GITHUB_ENVIRONMENT=$3

az account set --subscription $SUBSCRIPTION

echo "Current Subscription"
az account show

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

SUBSCRIPTION_ID=$(az account show --query id -o tsv)

TENANT_ID=$(az account show --query tenantId -o tsv)

CLIENT_ID=$(az ad app create --display-name ${APP_NAME} --query appId -o tsv)

SERVICE_PRINCIPAL_ID=$(az ad sp create --id $CLIENT_ID --query id -o tsv)

az role assignment create \
    --role contributor \
    --scope /subscriptions/$SUBSCRIPTION_ID \
    --subscription $SUBSCRIPTION_ID \
    --assignee-object-id $SERVICE_PRINCIPAL_ID \
    --assignee-principal-type ServicePrincipal

# Create a JSON configuration for the federated credentials
FEDERATED_CREDENTIALS="{
    \"name\": \"$GITHUB_ENVIRONMENT\",
    \"issuer\": \"https://token.actions.githubusercontent.com\",
    \"subject\": \"repo:$REPO:environment:$GITHUB_ENVIRONMENT\",
    \"description\": \"Configuration for $GITHUB_ENVIRONMENT environment\",
    \"audiences\": [
        \"api://AzureADTokenExchange\"
    ]
}"

az ad app federated-credential create --id $CLIENT_ID --parameters "$FEDERATED_CREDENTIALS"

gh secret set AZURE_CLIENT_ID --body $CLIENT_ID --env $GITHUB_ENVIRONMENT
gh secret set AZURE_TENANT_ID --body $TENANT_ID --env $GITHUB_ENVIRONMENT
gh secret set AZURE_SUBSCRIPTION_ID --body $SUBSCRIPTION_ID --env $GITHUB_ENVIRONMENT
