# Helm deployment of Gen3 data commons

Gen3 can be deployed in Kubernetes using this helm chart.  The templates folder holds the configurations for the various services.  There are a few files in this top level folder that are included in some templates until a more elegant way can be construed, such as python scripts and certificates and logos.

To deploy, use the helm command and specify the values file.  The DEV file (values-gen3k8dev.yaml) is the most tested at this point.


to install the ingress controller is
```
helm install nginx-ingress ingress-nginx/ingress-nginx     --NAMESPACE <namespace>     --set controller.replicaCount=2
```

To update the helm deploy

```
helm upgrade  gen3k8dev   -f <VALUES_FILE>  --namespace <NAMESPACE>   .
```
