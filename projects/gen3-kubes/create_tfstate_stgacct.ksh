#!/bin/bash

#Create initial storage account for tfstate to be remotely stored in AZ blob store.

set -x


RESOURCE_GROUP_NAME=k8s-gen3-tfw2
STORAGE_ACCOUNT_NAME=k8sgen3tf$RANDOM
CONTAINER_NAME=tfstate

# Create resource group
az group create --subscription "21a7a4d3-3641-4382-95a8-85ae72399ceb" --name $RESOURCE_GROUP_NAME --location "westus2"

# Create storage account
az storage account create --subscription "21a7a4d3-3641-4382-95a8-85ae72399ceb" --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query [0].value -o tsv)

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

echo "storage_account_name: $STORAGE_ACCOUNT_NAME"
echo "container_name: $CONTAINER_NAME"
echo "access_key: $ACCOUNT_KEY"

exit

Example output

LAMU02XLNBTJHC8:azure-kubernetes-starter rolinge$ ./create_tfstate_stgacct.ksh
+ RESOURCE_GROUP_NAME=k8s-gen3-tfw2
+ STORAGE_ACCOUNT_NAME=k8sgen3tf19336
+ CONTAINER_NAME=tfstate
+ az group create --subscription 21a7a4d3-3641-4382-95a8-85ae72399ceb --name k8s-gen3-tfw2 --location westus2
{
  "id": "/subscriptions/21a7a4d3-3641-4382-95a8-85ae72399ceb/resourceGroups/k8s-gen3-tfw2",
  "location": "westus2",
  "managedBy": null,
  "name": "k8s-gen3-tfw2",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}
+ az storage account create --subscription 21a7a4d3-3641-4382-95a8-85ae72399ceb --resource-group k8s-gen3-tfw2 --name k8sgen3tf19336 --sku Standard_LRS --encryption-services blob
{- Finished ..
  "accessTier": "Hot",
  "allowBlobPublicAccess": null,
  "azureFilesIdentityBasedAuthentication": null,
  "blobRestoreStatus": null,
  "creationTime": "2020-11-05T20:29:49.111530+00:00",
  "customDomain": null,
  "enableHttpsTrafficOnly": true,
  "encryption": {
    "keySource": "Microsoft.Storage",
    "keyVaultProperties": null,
    "requireInfrastructureEncryption": null,
    "services": {
      "blob": {
        "enabled": true,
        "keyType": "Account",
        "lastEnabledTime": "2020-11-05T20:29:49.189644+00:00"
      },
      "file": {
        "enabled": true,
        "keyType": "Account",
        "lastEnabledTime": "2020-11-05T20:29:49.189644+00:00"
      },
      "queue": null,
      "table": null
    }
  },
  "failoverInProgress": null,
  "geoReplicationStats": null,
  "id": "/subscriptions/21a7a4d3-3641-4382-95a8-85ae72399ceb/resourceGroups/k8s-gen3-tfw2/providers/Microsoft.Storage/storageAccounts/k8sgen3tf19336",
  "identity": null,
  "isHnsEnabled": null,
  "kind": "StorageV2",
  "largeFileSharesState": null,
  "lastGeoFailoverTime": null,
  "location": "westus2",
  "minimumTlsVersion": null,
  "name": "k8sgen3tf19336",
  "networkRuleSet": {
    "bypass": "AzureServices",
    "defaultAction": "Allow",
    "ipRules": [],
    "virtualNetworkRules": []
  },
  "primaryEndpoints": {
    "blob": "https://k8sgen3tf19336.blob.core.windows.net/",
    "dfs": "https://k8sgen3tf19336.dfs.core.windows.net/",
    "file": "https://k8sgen3tf19336.file.core.windows.net/",
    "internetEndpoints": null,
    "microsoftEndpoints": null,
    "queue": "https://k8sgen3tf19336.queue.core.windows.net/",
    "table": "https://k8sgen3tf19336.table.core.windows.net/",
    "web": "https://k8sgen3tf19336.z5.web.core.windows.net/"
  },
  "primaryLocation": "westus2",
  "privateEndpointConnections": [],
  "provisioningState": "Succeeded",
  "resourceGroup": "k8s-gen3-tfw2",
  "routingPreference": null,
  "secondaryEndpoints": null,
  "secondaryLocation": null,
  "sku": {
    "name": "Standard_LRS",
    "tier": "Standard"
  },
  "statusOfPrimary": "available",
  "statusOfSecondary": null,
  "tags": {},
  "type": "Microsoft.Storage/storageAccounts"
}
++ az storage account keys list --resource-group k8s-gen3-tfw2 --account-name k8sgen3tf19336 --query '[0].value' -o tsv
+ ACCOUNT_KEY=bcQkuWCHwLmN2KeJhaT8+tyICjAEVI+ET6LdonKfGhTyzqOMnGU11jOvItPPoKMMuj1C5lNa/pGRS5NAlky60Q==
+ az storage container create --name tfstate --account-name k8sgen3tf19336 --account-key bcQkuWCHwLmN2KeJhaT8+tyICjAEVI+ET6LdonKfGhTyzqOMnGU11jOvItPPoKMMuj1C5lNa/pGRS5NAlky60Q==
{
  "created": true
}
+ echo 'storage_account_name: k8sgen3tf19336'
storage_account_name: k8sgen3tf19336
+ echo 'container_name: tfstate'
container_name: tfstate
+ echo 'access_key: bcQkuWCHwLmN2KeJhaT8+tyICjAEVI+ET6LdonKfGhTyzqOMnGU11jOvItPPoKMMuj1C5lNa/pGRS5NAlky60Q=='
access_key: bcQkuWCHwLmN2KeJhaT8+tyICjAEVI+ET6LdonKfGhTyzqOMnGU11jOvItPPoKMMuj1C5lNa/pGRS5NAlky60Q==
+ exit
