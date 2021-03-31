# High level Installation

## Create service principle in Azure
This principle should have the ability to create and manage resource in the Azure subscription.  This will be the account used in Terraform.

## Clone the git repository and look at Azure-Infrastructure folder
## Initialize Terraform with the backend.
```
terraform init -backend-config=backend.tfvars
```

## Run the terraform scripts to create kubernetes, storage accounts and other resources

```
terraform plan -out=/tmp/myplan
terraform apply /tmp/myplan | tee /tmp/mygen3_environment.log
```

## Capture the output of Terraform and create the .kube/config file

```
az aks get-credentials --admin --name MyManagedCluster --resource-group MyResourceGroup
kubectl config set-context xxxx-admin
```

## Use kubernetes to create two namespaces

```
kubectl apply -f kubernetes-setup/namespaces.yaml
```

## Create Ingress controller in kubernetes

```
helm install nginx-ingress ingress-nginx/ingress-nginx \
    --namespace default \
    --set controller.replicaCount=2
```

## Decide on  your security model and either create or authorize accounts in K8s (optional)
You can also use RBAC in Azure to grant roles and clusterroles to peoples accounts.  This is an example.
```
cp kubernetes-setup/example-roles.yaml kubernetes-setup/roles.yaml
vi kubernetes-setup/roles.yaml
kubectl apply kubernetes-setup/roles.yaml
```

## create the database users and grant permissions.  Usually best to choose passwords that are complex and keep track, as you will need to enter them later.
```
#POSTGRES_PASSWORD will come from the Terraform Output

# Your Terraform Output will supply the values for these password strings. Manually enter them inside the single quotes.

CREATE USER fence_gen3dev_user with  createdb login password '<Password>';
CREATE USER arborist_gen3dev_user with  createdb login password '<Password>';
CREATE USER peregrine_gen3dev_user with  createdb login password '<Password>';
CREATE USER sheepdog_gen3dev_user with  createdb login password '<Password>';
CREATE USER indexd_gen3dev_user with  createdb login password '<Password>';

# Grant permissions on each db to the users
grant all on database fence_db to fence_gen3dev_user;
grant all on database arborist_db to arborist_gen3dev_user;
grant all on database indexd_db to indexd_gen3dev_user;
grant all on database metadata_db to sheepdog_gen3dev_user;
grant all on database metadata_db to peregrine_gen3dev_user;

# finally add an extension to the postgres arborist database
\c arborist_db
CREATE EXTENSION ltree ;
\q

```


## Customize the example-values.yaml file for your needs
Specific defnitions are available in the [VALUES](VALUES.md) instructions.
```
cp kubernetes-setup/gen3-values-example.yaml kubernetes-setup/gen3-values.yaml
vi kubernetes-setup/gen3-values.yaml
```

## Build the Gen3 instance using helm
```
cd gen3-helm/gen3kubernetes
ln -s ../../kubernetes-setup/gen3-values.yaml values.yaml
helm install <name> -f values.yaml .
```

## Customize and test your gen3 instance.
The configuration of variables is a huge part of this, espeically for authentication and authorization.

#get kubernetes credentials for the first admin
LAMU02XLNBTJHC8:kubernetes-setup rolinge$ az aks get-credentials --resource-group k8s-gen3-cg2 --name aks_k8sgen3cg2 --admin

kubectl apply namespaces.yaml
kubectl apply clusteroles, roles
kubectl apply StorageConfig
vi opendistro/customevalues.yaml   (change the name)
cd <opendistro>/helm  && helm install <name> -f customvalues.yaml .

use the info in database_setup.txt to create users and assign permissions.  This requires getting the postgres server name and postgres password from the terraform output.

in the gen3-helm directory, edit the values file for your specific settings.

helm install nginx-ingress ingress-nginx/ingress-nginx --namespace default --set controller.replicaCount=2

create ingres secret in file <secret-k8scg2dev-ingress-tls.yaml>
Add google oath stuff to the google developer console  (see fence documentation)
Create DNS cname in tech.optum.com
cp the values-gen3k8dev.yaml file to something that you will use for your helm install.  This is where the majority of changes will be made to control your gen3 instance configuration.


# DCE Kubernetes Sandbox (AKS)

## Objective
Quickly get started with the the Azure Kubernetes Service in your DCE sandbox. Learn and explore best practices with this [everything-as-code](https://openpracticelibrary.com/practice/everything-as-code/) implementation.

## Overview
DCE Kubernetes (AKS) deploys a VM scalesets and multi node pools Kubernetes cluster on Azure using AKS (Azure Kubernetes Service) and adds support for monitoring by attaching a Log Analytics solution.
