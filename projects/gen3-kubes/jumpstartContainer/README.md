# JumpstartContainer

## Purpose
Use this directory to build a container for doing certain utilities and debugging.  This container is launched and can be used for command line access to services inside the kubernetes system.

## Build
You will want to push this to your private registry.  Make sure to do docker login to that registry, and create the proper imagePullSecrets in Kubernetes.

```
cd JumpstartContainer
docker build -t <MyPrivateRegistryName.io>/jumpstartcontainer:latest .
docker push <MyPrivateRegistryName.io>/jumpstartcontainer:latest
```

## Deploy
The values-example file has a stanza at the end that allows you to speficy your own image.  The default image is centos:7 , which can have capabilities added when needed.  
