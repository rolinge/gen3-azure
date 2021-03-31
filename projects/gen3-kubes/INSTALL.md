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

## create the database users and grant permissions.
You can find unique generated passwords in the terraform output.  You can also use any passwords that you like.  Once you enter them into the config files, you don't have to deal with them anymore, so no reason to make them easy to remember.

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


## Get kubernetes credentials for the first admin
This command will populte your .kube/config file with the admin creds.
```
# use the az command to get the kubernetes
az aks get-credentials --resource-group <yourRG> --name <k8s_Clustername>  --admin
```
cd to the kubernetes_setup directory
```
kubectl apply -f namespaces.yaml      #create the namespaces
kubectl apply -f clusteroles -f roles #create the cluster roles and such
kubectl apply -f StorageConfig.yaml   #create the storage tier
# Now set your default namespace to the gen3 namespace
kubectl config  set-context --current --namespace=gen3k8dev
```


## Create the OpenDistro system in its own K8S namespace (substitute for ElasticSearch)
```
vi opendistro/customevalues.yaml   (change the name)
cd <opendistro>/helm  && helm install <name> -f customvalues.yaml  --namespace=gen3elastic .
```
## Change the OpenDistro default password and create a gen3 account
Follow the [instructions](https://opendistro.github.io/for-elasticsearch-docs/docs/security/access-control/users-roles/#internal_usersyml) or use the technique below.

 ### log into elasticsearch pod
Use the hash.sh program to create a hash of a new password.  The output of terraform has a suggestion for Opendistro (Elastic)

 ```
 kubectl exec -it --namespace=gen3elastic <xxx>elastic-opendistro-es-master-0 -- bash
[root@master-0]# cd /usr/share/elasticsearch/plugins/opendistro_security/securityconfig
chmod 755 /usr/share/elasticsearch/plugins/opendistro_security/tools/hash.sh
/usr/share/elasticsearch/plugins/opendistro_security/tools/hash.sh -p <MyNewAdminPassword>
/usr/share/elasticsearch/plugins/opendistro_security/tools/hash.sh -p <MyNewGen3Password>
 ```

### Update the Admin and Gen3 passwords in the internal_users.yml file
```
# add a user to the end of the file
echo "
gen3:
  hash: "xxx"
  reserved: false
  backend_roles:
  - "admin"
  description: "Gen3 user"
" >> internal_users.yml

vi internal_users.yml
# Find the stanzas for the admin and gen3 users and change the hash value to the out of the previous steps above. Save and exit.
```

### Exist the pod by typing exit
Or if you are fancy use ctl-d

## Create an ingress controller for the kubernetes cluster
This command creates the controller pair and Azure will give a public IP.  You can assign a domain name to it via the portal if you wish, or use your own DNS system to resolve your name.

```
helm install nginx-ingress ingress-nginx/ingress-nginx --namespace default --set controller.replicaCount=2
```

## Handle TLS/SSL

Create ingres secret in file <secret-k8sxxxdev-ingress-tls.yaml>
(Debt - This should be templated in Helm...)

## Authentication - Google
Follow the instructions for Fence to set up the google google developer console

## Authentication - Other Oauth


Create DNS cname in tech.optum.com
cp the values-gen3k8dev.yaml file to something that you will use for your helm install.  This is where the majority of changes will be made to control your gen3 instance configuration.



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
