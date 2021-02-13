
#!/bin/bash

echo "Gen3 BlobIndexTrigger function started"

date

set -e

echo "Starting SSH ..."
service ssh start

/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost
