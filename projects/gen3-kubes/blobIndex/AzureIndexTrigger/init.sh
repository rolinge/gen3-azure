
#!/bin/bash

echo "Gen3 BlobIndexTrigger function started"

date

if ( test ! -d /opt/shared/azgen3blobstorage ); then mkdir /opt/shared/azgen3blobstorage ; fi

set -e

echo "Starting SSH ..."
service ssh start

/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost
