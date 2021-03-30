# High level Installation

## Create service principle in Azure
This principle should have the ability to create and manage resource in the Azure subscription.  This will be the account used in Terraform.

## Clone the git repository and look at Azure-Infrastructure folder
## Initialize Terraform with the backend.
```
Insert command there
```

## Run the terraform scripts to create kubernetes, storage accounts and other resources

```
Insert command there
```

## Capture the output of Terraform and reate the .kube/config file

```
kubectl config set-context xxxx-admin
```

## Use kubernetes to create two namespaces

```
kubectl apply -f kubernetes-setup/namespaces.yaml
```

## Create Ingress controller in kubernetes

```
helm install nginx-ingress ingress-nginx/ingress-nginx \
    --namespace NAMESPACE \
    --set controller.replicaCount=2
```

## Decide on  your security model and either create or authorize accounts in K8s (optional)

```
cp kubernetes-setup/example-roles.yaml kubernetes-setup/roles.yaml
vi kubernetes-setup/roles.yaml
kubectl apply kubernetes-setup/roles.yaml
```
### customize the example-values.yaml file for your needs
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

Make sure to edit the following elements in your values*.yaml file.
- ENV:
- database_servername:
- fence.database.username:
- fence.database.db_password
- fence.enabledIDPProviders:  (select one or more)
- fence.base_url
- fence.googleOauth:  (if using google auth)
- fence.microsoftOauth: (if using Microsoft auth)
- fence.oktaOauth:   (ditto)
- fence.defaultLoginURLSuffix:
- fence.amazonStorageCreds  (probably don't need these since using Azure, but they are there if you want to have a cross cloud infra)
- fence.azCredentials:
- fence.azureBlobstores:
- fence.dataUploadBucket:
- fence.adminUsers:  (list of people with elevated privelages)
- fence.regularUsers:  (list of people with normal privelages)
- cacrtFiles: if using private certificates
- fence.jwt_private_key: (generate one if you want)
- fence.jwt_public_key:  (generate one if you want)
- arborist.database:
- image.imagePullSecrets:  (if you are using a private registry that requires authentication)
- ingress.hosts.host:
- ingress.hosts.host.paths.path.serviceName: (name of the service for revproxy)
- ingress.tls.secretName:
- ingress.hosts.secrestname.hosts:
- revproxy.crtFile:  (paths to the TLS files)
- revproxy.keyFile:
- revproxy.cacrtFile:
- peregrine.database:  (set user, password, etc)
- peregrine.gdcapi_secret_key:  (pick something)
- peregrine.hmac_key:           (pick something)
- peregrine.schemas:      (if you use a customer schema)
- tube.esrootcalocation:
- tube.elasticusername:
- elasticpasswordb64:
- tube.elastic.url
- sheepdog.database:  (user, password, databasename)
- sheepdog.schemas:   (in case you have a custom schema)
- indexd.database:  (user, password, databasename)
- indexd.username:  (make one up)
- indexd.password:  (make one up)
- portal.externalhostname:
- portal.gitops:
- portal.gitopslogo:
- jupyter.image:    (if you have a custom notebook)
- spark.spark_master: (your spark cluster)
-
# DCE Kubernetes Sandbox (AKS)

## Objective
Quickly get started with the the Azure Kubernetes Service in your DCE sandbox. Learn and explore best practices with this [everything-as-code](https://openpracticelibrary.com/practice/everything-as-code/) implementation.

## Overview
DCE Kubernetes (AKS) deploys a VM scalesets and multi node pools Kubernetes cluster on Azure using AKS (Azure Kubernetes Service) and adds support for monitoring by attaching a Log Analytics solution.
