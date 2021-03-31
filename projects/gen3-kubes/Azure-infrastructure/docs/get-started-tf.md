
idea from [cloudblogs](https://cloudblogs.microsoft.com/opensource/2017/11/09/s3cmd-amazon-s3-compatible-apps-azure-storage/)

```
az storage account create \
    --name "aaa" \
    --kind Storage \
    --sku Standard_LRS \
    --resource-group "rgbbb" \
    --subscription=<sub> \
    --location "eastus" \
 && az storage account show-connection-string \
    --name "aaa" \
    --subscription=<sub> \
    --resource-group "rgbbb" >> backend.tfvars \
&& az storage container create  \
    --name  tfstate \
    --subscription=<sub> \
    --resource-group "rgbbb" \
    --account-name aaa \
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
az ad sp create-for-rbac --name <yourNameHere>
{
  "appId": "<zzz>",
  "displayName": "<yourNameHere>",
  "name": "http://<yourNameHere>",
  "password": "<xxx>",
  "tenant": "<yyy>"
}
```
