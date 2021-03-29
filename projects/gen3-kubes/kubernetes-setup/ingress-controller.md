Use these commands to deploy the ingress controller into the namespace.  It will create the controller, load balancer, and a public ip in the resource group that holds the cluster node pools and such.  Use the DNS to add an entry to the controller's IP.  Then, create a CNAME in your favorite domain to have a vanity name.

(this command requires admin rights on the cluster)
(remember to substitute the NAMESPACE with your actual)
```helm install nginx-ingress ingress-nginx/ingress-nginx \
    --namespace NAMESPACE \
    --set controller.replicaCount=2
```

One could add the following switches to the above command if there are potential Windows members of any of the node pools.

```
--set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
--set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux \
--set controller.admissionWebhooks.patch.nodeSelector."beta\.kubernetes\.io/os"=linux
```
