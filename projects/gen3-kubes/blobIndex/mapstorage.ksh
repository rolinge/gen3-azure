#!/bin/bash

function usage()
{
	echo "
	usage:  mapstorage.ksh -s STGACCT -r RESOURCEGROUP -k STORAGEAPPKEY1 -n FUNCTIONAPPNAME  -f FILESHARENAME [-u] "
}

RG=gen3-compose-vprh
STGACCT=azgen3blobstorage
FILESHARENAME=azgen3blobstorage
FUNCTIONAPPNAME=blobindexfuncdevxhlgk
command=add

while getopts "f:s:un:k:r:" OPTION; do
    case $OPTION in
    k)
		STORAGEAPPKEY1=$OPTARG
		stgkey=true
		;;
    r)
        RG=$OPTARG
        ;;
    u)
        command="update"
        ;;
    n)
        FUNCTIONAPPNAME=$OPTARG
        ;;
    f)
        FILESHARENAME=$OPTARG
        ;;
    s)
        STGACCT=$OPTARG
        ;;
    *)
        echo "Incorrect options provided"
		usage
        exit 1
        ;;
    esac
done

if [[ ! $stgkey ]]
then
    echo "Storage key is required, use option -k" >&2
    exit 1
fi


set -x

az webapp config storage-account add \
	--resource-group $RG  \
	--storage-type "AzureFiles" \
	--account-name $STGACCT \
	--share-name $FILESHARENAME \
	--mount-path /opt/shared \
	-n $FUNCTIONAPPNAME \
	--custom-id "CustomID" \
	--access-key $STORAGEAPPKEY1
