# Settins for SSL in Gen3 Data Commons
The job of setting up and managing SSL(TLS) for any web site is not for the timid, especially if you have a private CA.

## Preperation
1. Decide on a URL for your site.
2. Generate a CSR
3. Get the CSR signed by a CA, or sign using your own CA
4. Capture certificate file, key file, and ca-certificate file.  (PEM format)
5. Copy those files to the 'secrets' directory.
   1. projects/gen3kubes/secrets/<certfile>.PEM
   2. projects/gen3kubes/secrets<keyfile>.PEM
   3. projects/gen3kubes/secrets<cacert>.PEM

## Create a Kubernetes secret yaml file
Each file must be encoded with base64 and the string placed in the secret yaml file as below.

base64 the files
```
cat <certfile>.PEM | base64 -b 0 >certfile.crt.b64
cat <keyfile>.PEM | base64 -b 0  >keyfile.crt.b64
```
Replace those base64 strings into the secrets file template below.
```
apiVersion: v1
data:
  tls.crt:   <file contents of certfile.b64>
  tls.key:   <file contents of certfile.b64>
kind: Secret
metadata:
  name: k8scg2dev-ingress-tls
  namespace: gen3k8dev
type: kubernetes.io/tls
```
## Load the secret into Kubernetes
Before deploying with Helm, This secret file will get loaded into the ingress object and provide TLS termination for your site.
```
kubectl apply -f <secretfile.yaml>
```
