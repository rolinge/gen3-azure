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

## Map the file share to the functionapp
Terraform attempts to do this action via the null resource.  If it fails due to a local issue,  You will need to know the resource group and get the storage account connectionstring, and the name of the blob index functionapp in order to run this command.

```
az webapp config storage-account add \
    --resource-group <RESOURCEGROUPNAME>  --storage-type AzureFiles \
    --account-name azgen3blobstorage --share-name azgen3blobstorage \
    --mount-path /opt/shared -n <BLOBINDEXFUNCTIONAPPNAME> \
    --custom-id CustomID --access-key <CONNECTIONSTRING>

```

## Use kubernetes to create two namespaces
```
kubectl apply -f kubernetes-setup/namespaces.yaml
```

## Create an ingress controller for the kubernetes cluster
This command creates the controller pair and Azure will give a public IP.  You can assign a domain name to it via the portal if you wish, or use your own DNS system to resolve your name.

```
helm repo add nginx-stable https://helm.nginx.com/stable && helm repo update
helm install nginx-ingress nginx-stable/nginx-ingress \
    --namespace default \
    --set controller.replicaCount=2
```

## Decide on  your security model and either create or authorize accounts in K8s (optional)
You can also use RBAC in Azure to grant roles and clusterroles to peoples accounts.  This is an example.
```
cp restricted/example-roles.yaml restricted/myroles.yaml
vi restricted/myroles.yaml  #Make changes for YOUR system users and groups.
kubectl apply -f restricted/myroles.yaml
```

## Create a jump-server pod that can be used to run postgres commands.

```
kubectl apply -f kubernetes_setup/initialjumpserver.yaml
<wait about a minute for pod to start>
kubectl exec -it --namespace=gen3k8dev jumpserver-initial -- bash
  >> yum -y update && yum -y  install postgresql
```

## create the database users and grant permissions.
Terraform out contains the complete script that resembles what is below.  Just copy and past the entire script into the postgres command line using the jumpserver pod above.

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
cp clusterroles-example.yaml clusterroles.yaml
cp roles-example.yaml roles.yaml
# Change these two files to your needs
kubectl apply -f namespaces.yaml                  #create the namespaces
kubectl apply -f clusteroles.yaml -f roles.yaml   #create the cluster roles and such
kubectl apply -f StorageConfig.yaml               #create the storage tier
# Now set your default namespace to the gen3 namespace
kubectl config  set-context --current --namespace=gen3k8dev
```


## Create the OpenDistro system in its own K8S namespace (substitute for ElasticSearch)
```
vi opendistro/customevalues.yaml   (change the name)
cd <opendistro>/helm  && helm install <name> -f customvalues.yaml  --namespace=gen3elastic .
```
## Handle TLS/SSL
You need to decide on the URL for your site, this drives many settings later.  For instance, you may want the site to be https://gen3-is-awesome.mycompany.com

Then go get SSL/TLS certificates created for this domain name and set it up in DNS as an alias for the ingres.

Use the two TLS files (certificate and key) to create an ingres secret of type TLS in the file <secret-k8sxxxdev-ingress-tls.yaml>.  Create this secret in kubernetes using the kubectl apply command.  The secret is used by the ingress to terminate ssl to the browser.
Follow the [instructions here](SSL.md)

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
helm install <name> -f values-myinstance.yaml --namespace=gen3k8dev  .
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
