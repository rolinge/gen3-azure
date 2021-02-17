# AzureIndexTrigger

The purpose of this code is to create a docker container, hosted as an Azure function, that will update the metadata
on a blob that is uploaded via the gen3 client. Specific fields (size, hashes, urls) need to be filled in AFTER a file
is uploaded by the client.  The function is triggered by an eventGrid resource in Azure that fires off the function
after a blob is finished uploading.

## Dependancies
This code runs in a Azure functionapp that is hosted in an application_Service , all provisioned by Terraform.  The function itself is deployed va VS Code, but it is just a docker container that is uploaded and built in Azure.  In the future we will move the container build into a Jenkins workflow to manage updates and releases.

## Extra Steps
-  At this point there is a requirement to map a file share volume into the function after it is created in Azure.  Sadly, this is not yet supported by terraform, so it must be done manually.  In a future version this requirement should go away as there is no reason for this procedure to store any data.  There is a commandscript named mapstorage.ksh that can be used for this purpose.

## Deploy in portal
1. do a docker build on your desktop.

  In a terminal window,

        cd to the directory clinicogenomics/projects/gen3-kubes/blobIndex/AzureIndexTrigger
        $ docker build -t gen3/blobtriggerdocker:{yournamehere}

2. push docker container to the registry
        $ docker login acrgen3klnow.azurecr.io
        user is acrgen3klnow
        -password is available in the Azure portal
        $ docker push gen3/blobtriggerdocker:{yournamehere}

3. update the app service to use the new container
    (Look in the configuration of the app service [here](https://portal.azure.com/#@uhgazure.onmicrosoft.com/resource/subscriptions/21a7a4d3-3641-4382-95a8-85ae72399ceb/resourceGroups/k8s-gen3/providers/Microsoft.Web/sites/blobindexfuncdevklnow/AppServiceDeploymentCenter))

        update the tag to your new tag,
        click save.
        Function app should restart.

4. Test and upload a file
  - use the gen3-client to upload a file
  - look at log output in the function app.
