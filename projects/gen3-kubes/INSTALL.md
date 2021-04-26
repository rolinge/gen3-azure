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

All subsequent commands are run from the folder projects/gen3-kubes/

```
cd Azure-Infrastructure
terraform init -backend-config=backend.tfvars
```
## Create a PFX certificate for TLS and store it in the Assets directory

Select PKCS12 when downlading which should be in .pfx format.


## Run the terraform scripts to create kubernetes, storage accounts and other resources

Beofre you start, install and update your local Azure CLI with "az extension add --name aks-preview". This is required as part of the Application gateway configuration. 

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
Update the namespace.yaml with the appropriate values for the environment you are building.
```
kubectl apply -f kubernetes-setup/namespaces.yaml
```

## Create a jump-server pod that can be used to run postgres commands.

```
kubectl apply --namespace=default -f kubernetes-setup/initialjumpserver.yaml
sleep 60  # wait for pod to start
kubectl exec -it --namespace=default jumpserver-initial -- yum -y update && kubectl exec -it --namespace=default jumpserver-initial -- yum -y  install postgresql
```

## create the database users and grant permissions.
Terraform out contains the complete script that **resembles** what is below.  Just copy and past the entire script into the postgres command line using the jumpserver pod above.

Connect to the postgres server from the jump server:
psql -h pgtestuqgns.postgres.database.azure.com -U postgres@pgtestuqgns.postgres.database.azure.com -d postgres

```
kubectl exec -it --namespace=default jumpserver-initial -- psql -h pgtestuqgns.postgres.database.azure.com -U postgres@pgtestuqgns.postgres.database.azure.com -d postgres

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
## Modify cluster settings
cd gen3-helm/gen3kubernetes/templates/cluster. You may want to modify the files to suit your needs.

clusterroles.yaml - security roles for managing the azure kubernetes service

namespaces.yaml - not used. implemented manually prior in this version of the automation scrip. 

roles.yaml - update the namespace for the particular environment. 

StorageClass-gen3.yaml


## Handle TLS/SSL
You need to decide on the URL for your site, this drives many settings later.  For instance, you may want the site to be https://gen3-is-awesome.mycompany.com 

Then go get SSL/TLS certificates created for this domain name and set it up in DNS as an alias for the ingres.

Go to Optum Venafi service to request a cert
https://certificateservices.optum.com/aperture/dashboard/certificate-dashboard
Inventory->Certificates-> Create a New Certificate
Select Single Site (Comodo)

Download new cert
unzip and cd into folder with certs
run
openssl rsa -in gen3infradev.optum.com.key -out gen3infradev.optum.com.npp.key
cat gen3infradev.optum.com.crt | base64 -b 0 >certfile.crt.b64
cat gen3infradev.optum.com.npp.key | base64 -b 0 >keyfile.crt.b64

Copy the Comodo certificates generated before into the .../gen3-kubes/gen3-helm/gen3kubernetes/assets folder.

Use the two TLS files (certificate and key) to create an ingres secret of type TLS in the file <secret-k8sxxxdev-ingress-tls.yaml>.
Go into the secrets folder to copy and update the secret-gen3-enviornment-ingress-tls-template.yaml
example: secret-gen3-dev-ingress-tls.yaml
update the name, namespace, tls.crt and tls.key values. 
tls.crt value comes from the certfile.crt.b64 previously generated, and the tls.key value comes from the keyfile.crt.b64 file previously generated

Create this secret in kubernetes using the kubectl apply command.  The secret is used by the ingress to terminate ssl to the browser.

'''
kubectl apply -f secret-gen3test-ingress-tls.yaml
'''
## Customize Gen3 settings to  your specific needs
cp the projects/gen3-kubes/gen3-helm/gen3kubernetes/values-example.yaml file to something that you will use for your helm install.  This is where the majority of changes will be made to control your gen3 instance configuration.  The configuration of variables is a huge part of this, espeically for authentication and authorization.

Specific defnitions are available in the [VALUES](VALUES.md) instructions.
```
cp projects/gen3-kubes/gen3-helm/gen3kubernetes/values-example.yaml \
   projects/gen3-kubes/gen3-helm/gen3kubernetes/values-myinstance.yaml
vi projects/gen3-kubes/gen3-helm/gen3kubernetes/values-myinstance.yaml
```
### Update cert information in the values file. 

In the cacrtFiles section, add the signing cert authority and if required, the intermediaite cert as well. Example:
cacrtFiles:
    - name: "SigningCert.crt"
      fileLocation: "assets/COMODO RSA Certification Authority.crt"
    - name: "intermediateCert.crt"
      fileLocation: "assets/COMODO RSA Organization Validation Secure Server CA.crt"

Update the jwt_private_key and jwt_public_key values. 
Navigate to the ../gen3-kubes/kubernetes-setup directory
run fence-jwt-setup.ksh
I new folder will be created named genceJwtKeys. Navigate to the newly created jwt_private and jwt_public files. Cat the values and update the values within the values-environment.yaml. 


Update the ingress section, under the tls section and update the secretName with the secret created earlier via the <secret-k8sxxxdev-ingress-tls.yaml> file that was used. 
example:
- secretName: gen3test-ingress-tls
      hosts:
        - gen3test.optum.com

### Update additional values in values-myenvironment.yaml

These variables should have the same value:
ENV
ingress -> serviceName 
revproxy -> crtFile
revproxy -> keyFile
revproxy -> cacrtFile
indexd -> username
indexd -> password

Update the following with the new URL that will be used
base_url
externalhostname
host
database_servername

Update all database host, usernames, and passwords.

Update the location of any custom docker images being used. 
Currently we use custom images for fence and jupyter.

### Update Authentication Identity Providers
In the fence section, update the Identity Provider to be microsoft, for use with our AzureAD instance.
defaultIDPProvider: microsoft
Under enabledIDPProviders: enable only microsoft
- name: "microsoft"
      loginButtonText: "Optum Login"
Update the AppID and Secret required to conect to Azure under the microsoftOauth section.
microsoftOauth:
    client_id: 'xxxxxx'
    client_secret: 'xxxxxx'

Update the defaultLoginURLSuffix: 'login/microsoft'

Update any admin and normal users that will be allowed into the Gen3 enviornment. 
adminUsers
regularUsers

Add Azure Cluster admins under the kubernetescluster: section.

### If using google for testing: Authentication - Google
Follow the [instructions for Fence](https://github.com/uc-cdis/fence/blob/master/README.md#oidc--oauth2) to set up the google google developer console

### Authentication - Other Oauth
Updates in the values.yaml file for help.
[instructions for Fence](https://github.com/uc-cdis/fence/blob/master/README.md#oidc--oauth2)


## Create Registry pull secret
Before you can run start your kubernetes cluster, you need to create a registry pull secret, so custom images can be pulled from the azure container registry.

```
	kubectl create secret docker-registry "registrypullsecret" \
	    --namespace "gen3k8dev" \
	    --docker-server=<container-registry-name>.azurecr.io \
	    --docker-username=<service-principal-ID> \
	    --docker-password=<service-principal-password>


- For secret-name you can use anything you'd like, but can use: registrypullsecret if you want to make fewer edits to the values-myinstance.yml file.
- For namespace this should be the kubectl namepsace you want to create your cluster in, we created 2: gen3k8dev and gen3elastic, use gen3k8dev.
- For docker-server use the acrHost from the terraform output.
- For service-principal-ID use acrPassword from the terraform output.
- For service-principal-password use acrUsername from the terraform output.

```
## Build the Gen3 instance using helm

Make up a name to define this instance.  It will be used for all subsequent helm commands.  Here we use the name "dev"
```
cd gen3-helm/gen3kubernetes
helm install "dev" -f values-myinstance.yaml  --namespace=gen3k8dev .
```
## Now set your default namespace to the gen3 namespace
kubectl config  set-context --current --namespace=gen3k8dev

## Create DNS cname in your favorite DNS resolver
The IP address can be found in the public-ip that is created in the kubernetes resources such as the INGRES controller in the default namespace.
```
kubectl describe  ingress gen3-ingress-test | grep Address
```
Update your DNS Alias to resolve to the new puboic IP. 


Properties -> Infrastructure Resource Group -> kubernetes public ip address -> configuration. Updtae DNS name lable. This URL will be the alias used by internal DNS cname config.


## Update the secrets for backend automation

1. Log into the portal and select the 'Profile' tab
2. Create an api key by pressing the "Creat API key" button and saving the file on your workstations
3. use the included helper script to parse the file and create the azure cli commands.  The script is found at [projects/gen3-kubes/kubernetes-setup/update-secrets.ksh](kubernetes-setup/update-secrets.ksh)
4. Copy and paste the commands and run them. (Mac and Linux)
5. Use this same API credential file to set up gen3-client for uploads.   (not docuemnted here)

az keyvault secret set --name gen3keyid --value "xxx" --vault-name kvtestuqgns

az keyvault secret set --name gen3KeySecret  --value "yyy"  --vault-name kvtestuqgns


## Create the OpenDistro system in its own K8S namespace (substitute for ElasticSearch)
```
cd gen3-kubes/elastic-search-helm/opendistro-es
vi customvalues.yaml   (change the name of cluster)
helm install <name> -f customvalues.yaml  --namespace=gen3elastic .
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
- helm delete <name>                             # Start over
- kubectl delete pods <pod_name>                 # easy way to restart a pods
- kubectl rollout restart deployment <deployment> # easy way to restart a deployment when config changes.
```
