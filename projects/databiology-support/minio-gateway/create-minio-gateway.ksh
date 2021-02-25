# MINIO_ROOT_PASSWORD generated from base64 of "5C1851B5-DFFD-44A5-9ED2-E5BDB621C464"
az container create --resource-group optumdbedev \
            --name optumdbedev-color-minio \
            --image minio/minio \
            --dns-name-label optumdbedev-color-minio \
            --ports 80 9000 \
            --environment-variables \
                  "AZURE_STORAGE_ACCOUNT=colordropbox" \
                  "AZURE_STORAGE_KEY=DsDRhqs2/X1Eqv1eyL/7nc754ewO4AXig9RqsT2Dr6SHrvqG2IaLmZ/OQUW6dq4Wb5RGoQ0BXBedKzB6fDcYmA==" \
                  "MINIO_ROOT_USER=colordrop01" \
                  "MINIO_ROOT_PASSWORD=NUMxODUxQjUtREZGRC00NEE1LTlFRDItRTVCREI2MjFDNDY0Cg==" \
            --command-line /usr/bin/minio\ gateway\ azure    \
            --cpu 1 \
            --memory 1

# create the reverse proxy to do ssl/tls
az container create --resource-group optumdbedev \
            --name optumdbedev-color-proxy \
            --image nginx:latest \
            --dns-name-label optumdbedev-color-drop \
            --ports 80  443  \
            --azure-file-volume-account-name colordropbox \
            --azure-file-volume-mount-path /etc/nginx/conf.d \
            --azure-file-volume-share-name aci \
            --cpu 1 \
            --memory 1 \
            --azure-file-volume-account-key "DsDRhqs2/X1Eqv1eyL/7nc754ewO4AXig9RqsT2Dr6SHrvqG2IaLmZ/OQUW6dq4Wb5RGoQ0BXBedKzB6fDcYmA=="


exit


#Testing
az container create --resource-group rolinge-01  \
            --name optumdbedev-color-miniotest \
            --image minio/minio \
            --ports  9000 \
            --environment-variables \
                  "AZURE_STORAGE_ACCOUNT=colordropbox" \
                  "AZURE_STORAGE_KEY=DsDRhqs2/X1Eqv1eyL/7nc754ewO4AXig9RqsT2Dr6SHrvqG2IaLmZ/OQUW6dq4Wb5RGoQ0BXBedKzB6fDcYmA==" \
                  "MINIO_ROOT_USER=colordrop01" \
                  "MINIO_ROOT_PASSWORD=NUMxODUxQjUtREZGRC00NEE1LTlFRDItRTVCREI2MjFDNDY0Cg==" \
            --command-line /usr/bin/minio\ gateway\ azure    \
            --cpu 1 \
            --memory 1 \
            --vnet optumdbedevrmo \
            --vnet-address-prefix 172.32.0.0/16 \
            --subnet minio \
            --subnet-address-prefix 172.32.3.0/24
