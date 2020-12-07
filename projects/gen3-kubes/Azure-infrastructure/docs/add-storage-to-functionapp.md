az webapp config storage-account add \
    --resource-group gen3-compose-vprh  --storage-type AzureFiles \
    --account-name azgen3blobstorage --share-name azgen3blobstorage \
    --mount-path /opt/shared -n blobindexfuncdevxhlgk \
    --custom-id CustomID --access-key "DefaultEndpointsProtocol=https;AccountName=azgen3blobstorage;AccountKey=0yzBB7W6H7Tz1wtmGHukXUuVA91YiYGn5anpPFgq4NoeccZ1rcqMgyaRCYwSYoZpUqMT0YJx1dWXTDjUQMltZQ==;EndpointSuffix=core.windows.net"
