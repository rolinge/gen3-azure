
idea from [cloudblogs](https://cloudblogs.microsoft.com/opensource/2017/11/09/s3cmd-amazon-s3-compatible-apps-azure-storage/)

```
az storage account create \
    --name "aksrmo" \
    --kind Storage \
    --sku Standard_LRS \
    --resource-group "rolinge-01" \
    --subscription=29bd0546-ff5b-437c-bab6-aea5fc7e5653 \
    --location "eastus" \
 && az storage account show-connection-string \
    --name "aksrmo" \
    --subscription=29bd0546-ff5b-437c-bab6-aea5fc7e5653 \
    --resource-group "rolinge-01" >> backend.tfvars \
&& az storage container create  \
    --name  tfstate \
    --subscription=29bd0546-ff5b-437c-bab6-aea5fc7e5653 \
    --resource-group "rolinge-01" \
    --account-name aksrmo \
    --auth-mode login
```

Now edit the backend.tfvars to use the new connection secretkey, rm the .terraform/terraform.tfstate  and
do "terraform init -backend-config=backend.tfvars"

it should look like the following...

resource_group_name = "rolinge-01"
storage_account_name = "aksrmo"
container_name = "tfstate"
access_key = "<key>"
key = "azure-aksrmo.tfstate"


Get a service principal created using these commands.
Enter the appID and the password into the variables.tf file as the client_id and client_secret

```
az ad sp create-for-rbac --name rmo-dce-aks
{
  "appId": "f8b8b944-81bf-4c76-b460-f9e17beef02d",
  "displayName": "rmo-dce-aks",
  "name": "http://rmo-dce-aks",
  "password": "XDUjUzCdgBc_TTpVaCChDP41-rNYR21~o4",
  "tenant": "db05faca-c82a-4b9d-b9c5-0f64b6755421"
}
```
