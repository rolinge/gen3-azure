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
