#!/bin/bash

# This  script will assist the user in updating the secrets for the gen3blobindex.
# The input is the credentials file that is downladed from the GEN3 portal as an api key.
# The program will attempt to get the name of the keyvault based on the resource group
# passed as a paramter.  Then it will parse the input file and construct the statements
# to update the secrets in the keyvault.

usage () {
  echo "
  usage: update-secrets.ksh <cred-file> <resource-group>

  resource groups choose from...
  "
  az group list | jq .[].name
  exit
}

if [ -z "$1" -o -z "$2"  ];
 then
  usage;
 fi

RG=$2
CRED=$1

kv=`az keyvault list --resource-group $RG | jq .[0].name | tr -d \" `

set -x
az keyvault secret set --name gen3keyid     --value $(jq .key_id  < $CRED | tr -d \") --vault-name $kv
az keyvault secret set --name gen3KeySecret --value $(jq .api_key < $CRED | tr -d \") --vault-name $kv
