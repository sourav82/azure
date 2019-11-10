This is for terraform script to spawn resources in Azure

Some of pre-requisites to start using this. From Azure shell use below 

az account list --query "[].{name:name, subscriptionId:id, tenantId:tenantId}"
export SUBSCRIPTION_ID="your subscription id"
az account set --subscripion="$SUBSCRIPTION_ID"

#Add service principal for terraform to provision resources in Azure

az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${SUBSCRIPTION_ID}"
export ARM_SUBSCRIPTION_ID=$SUBSCRIPTION_ID
export ARM_CLIENT_ID="created client id"
export ARM_CLIENT_SECRET="created password"
export ARM_TENANT_ID="created tenant id"
export ARM_ENVIRONMENT=public
