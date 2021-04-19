# High level Installation

## Create service principle in Azure
This principle should have the ability to create and manage resource in the Azure subscription.  This will be the account used in Terraform. This only needs to be done once per Azure subscription. The same AppID created for terraform can be re-used. Create One for non-prod subscription, and one for a prod subscription. 

## Clone the git repository and look at Azure-Infrastructure folder
Update the following variable files as appropriate the the environment you are building out. 
backend.tf
backend.tfvars
CREDENTIALS.auto.tfvars
terraform.tfvars
variables.tf

## Initialize Terraform with the backend.
```
terraform init -backend-config=backend.tfvars
```
? under what conditions do we need to delete the local and azure state file ?
## Initialize Terraform with the backend.

All subsequent commands are run from the folder projects/gen3-kubes/

```
cd Azure-Infrastructure
terraform init -backend-config=backend.tfvars
```
## Create a PFX certificate for TLS and store it in the Assets directory

## Make changes to the terraform.tfvars file to reflect your wishes.

## Run the terraform scripts to create kubernetes, storage accounts and other resources

```
terraform plan -out=/tmp/myplan
terraform apply /tmp/myplan | tee /tmp/mygen3_environment.log

cd ..
```

Capture the output of Terraform , always a good idea to save the text as it comes in handy later.

## Create your .kube/config file

```
az aks get-credentials --admin --name MyManagedCluster --resource-group MyResourceGroup
```

## Create namespaces in kubernetes

```
cd templates/cluster
kubectl apply -f namespaces.yaml 
```

## Decide on  your security model and either create or authorize accounts in K8s (optional)
You can also use RBAC in Azure to grant roles and clusterroles to peoples accounts.  This is an example.
Nedt to add the RBAC group id's to the clusterroles if you want others to be able to manage your K8s instance.  Ignore this unless you are familiar with [AKS RBAC](https://docs.microsoft.com/en-us/azure/aks/azure-ad-rbac).
```
vi gen3-helm/gen3kubernetes/templates/cluster/clusterroles.yaml
```

## Create a jump-server pod that can be used to run postgres commands.

```
kubectl apply --namespace=default -f kubernetes_setup/initialjumpserver.yaml
sleep 60  # wait for pod to start
kubectl exec -it --namespace=default jumpserver-initial -- bash
  >> yum -y update && yum -y  install postgresql
```


## create the database users and grant permissions.
Terraform out contains the complete script that **resembles** what is below.  Just copy and past the entire script into the postgres command line using the jumpserver pod above.

```
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


cd to the kubernetes_setup directory.  You may want to modify the clusterroles.yaml file to grant specific permissions to different groups in your organization.
```
cd kubernets-setup
kubectl config  set-context --current --namespace=gen3k8dev
```


## Create the OpenDistro system in its own K8S namespace (substitute for ElasticSearch)
```
cd elastic-search-helm
vi opendistro/customevalues.yaml   (change the name)
cd <opendistro>/helm  && helm install <name> -f customvalues.yaml  --namespace=gen3elastic .
cd ..
```

## Authentication - Google
Follow the [instructions for Fence](https://github.com/uc-cdis/fence/blob/master/README.md#oidc--oauth2) to set up the google google developer console

## Authentication - Other Oauth
Updates in the values.yaml file for help.
[instructions for Fence](https://github.com/uc-cdis/fence/blob/master/README.md#oidc--oauth2)

## Create DNS cname in your favorite DNS resolver
The IP address can be found in the public-ip that is created in the kubernetes resources such as the INGRES controller in the default namespace.
```
kubectl describe  ingress gen3-ingress-dev | grep Address
```

## Customize Gen3 settings to  your specific needs
cp the projects/gen3-kubes/gen3-helm/gen3kubernetes/values-example.yaml file to something that you will use for your helm install.  This is where the majority of changes will be made to control your gen3 instance configuration.  The configuration of variables is a huge part of this, espeically for authentication and authorization.

Specific defnitions are available in the [VALUES](VALUES.md) instructions.
```
cp projects/gen3-kubes/gen3-helm/gen3kubernetes/values-example.yaml \
   projects/gen3-kubes/gen3-helm/gen3kubernetes/values-myinstance.yaml
vi projects/gen3-kubes/gen3-helm/gen3kubernetes/values-myinstance.yaml
```

## Build the Gen3 instance using helm

Make up a name to define this instance.  It will be used for all subsequent helm commands.
```
cd projects/gen3-kubes/gen3-helm/gen3kubernetes
helm install <name> -f values-myinstance.yaml  --namespace=gen3k8dev .
```

## Create the OpenDistro system in its own K8S namespace (substitute for ElasticSearch)
```
cd gen3-kubes/elastic-search-helm/opendistro-es
vi customvalues.yaml   (change the name)
helm install <name> -f customvalues.yaml  --namespace=gen3elastic .
```

## Create Registry pull secret
Before you can run start your kubernetes cluster, you need to create a registry pull secret, so custom images can be pulled from the azure container registry.

```
	kubectl create secret docker-registry <secret-name> \
	    --namespace <namespace> \
	    --docker-server=<container-registry-name>.azurecr.io \
	    --docker-username=<service-principal-ID> \
	    --docker-password=<service-principal-password>
```

- For secret-name you can use anything you'd like, but can use: registrypullsecret if you want to make fewer edits to the values-myinstance.yml file. 
- For namespace this should be the kubectl namepsace you want to create your cluster in, we created 2: gen3k8dev and gen3elastic, use gen3k8dev.
- For docker-server use the acrHost from the terraform output.
- For service-principal-ID use acrPassword from the terraform output.
- For service-principal-password use acrUsername from the terraform output.



## Now set your default namespace to the gen3 namespace
kubectl config  set-context --current --namespace=gen3k8dev
=======

## Update the secrets for backend automation

One of the processes that runs in the background uses secrets from the keyvault that need to be entered by someone with access to the portal.  So the procedure follows...


1. Log into the portal and select the 'Profile' tab
2. Create an api key by pressing the "Creat API key" button and saving the file on your workstations
3. use the included helper script to parse the file and create the azure cli commands.  The script is found at [projects/gen3-kubes/kubernetes-setup/update-secrets.ksh](kubernetes-setup/update-secrets.ksh)
4. Copy and paste the commands and run them. (Mac and Linux)
5. Use this same API credential file to set up gen3-client for uploads.   (not docuemnted here)

The commands look something like this

```
az keyvault secret set --name gen3keyid     --value "myKeyID" --vault-name <MyKeyVault> --resource-group <MyResourceGroup>
az keyvault secret set --name gen3KeySecret --value "MyAPIKey" --vault-name <MyKeyVault> --resource-group <MyResourceGroup>
```


## Happy Gen3!
While this is a very complex process with many steps, with a little debugging you can have a system up in no time.  Probably the most difficult service to get running is fence, as it interacts with external entities like cloud storage and authentication.  Pay VERY close attention to detail when entering the OAUTH settings.

The following commands will help you diagnose and solve problems should they arise.  This is no substitute for a solid grasp of helm and kubernetes.
```
- kubectl get pods           # see which pods are running or dead
- kubectl logs -f <pod-name> # see real time output from a pod
- kubectl exec -it <pod-name> -- bash   # run linux command line in a running pod.
- kubectl delete deployment <deployment-name> # useful before running helm again, forces a redeploy.
- kubectl scale deployment --replicas=n <deployment-name>   # add or remove counts of containers in a set
- helm upgrade <name> --namespace=k8sgen3dev .   # new configuration after changing variables
```
