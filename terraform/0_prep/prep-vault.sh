#!/usr/bin/env bash

# Step 1: Get access token from Azure Instance Metadata Service
access_token=$(curl -s 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/' -H Metadata:true | jq -r .access_token)

# Step 2: Use the access token to call the Azure Resource Manager REST API and get the tenant ID
tenant_info=$(curl -X GET -H "Authorization: Bearer $access_token" 'https://management.azure.com/tenants?api-version=2020-01-01')

tenantId=$(echo "$tenant_info" | jq -r .value[0].tenantId)

# Step 3: Get the metadata from Azure Instance Metadata Service (IMDS)
metadata=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2021-02-01")

# echo $metadata # If you want to print the entire metadata JSON

# Step 4: Extract the resourceId from the metadata JSON
resourceId=$(echo $metadata | jq -r '.compute.resourceId')

# Step 5: Extract the subscriptionId from the resourceId
subscriptionId=$(echo $resourceId | cut -d'/' -f3)

# Step 6: Enable vault with managed id
vault write azure/config \
    subscription_id=$subscriptionId \
    tenant_id=$tenantId

# Step 7: Create a role with a 1 hour max session
vault write azure/roles/access-to-sub ttl=1h azure_roles=-<<EOF
    [
        {
            "role_name": "Contributor",
            "scope":  "/subscriptions/${subscriptionId}"
        }
    ]
EOF
