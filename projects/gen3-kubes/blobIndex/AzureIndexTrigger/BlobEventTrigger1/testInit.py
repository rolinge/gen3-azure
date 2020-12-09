import json
import logging
import sys, os, json
import base64, hashlib
from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient, __version__
from azure.storage.blob import ResourceTypes, AccountSasPermissions, generate_account_sas
from gen3.auth import Gen3Auth
from gen3.index import Gen3Index
from datetime import datetime, timedelta
import azure.functions as func
from datetime import datetime


if True:
    event33 = "event33"
    result = """{"id": "0a13137c-e01e-003d-298e-be3d1c06b713", 
                "data": {
                    "api": "PutBlob", 
                    "clientRequestId": "42941790-1b0d-4895-b4e4-62d78f179039", 
                    "requestId": "0a13137c-e01e-003d-298e-be3d1c000000", 
                    "eTag": "0x8D88CA59C68A4CC", 
                    "contentType": "image/png", 
                    "contentLength": 11000, 
                    "blobType": "BlockBlob", 
                    "blobUrl": "https://azgen3blobstorage.blob.core.windows.net/azgen3blobstorage/d05db566-8ace-47f6-8df6-b242e6f157fe/future.png", 
                    "url": "https://azgen3blobstorage.blob.core.windows.net/azgen3blobstorage/d05db566-8ace-47f6-8df6-b242e6f157fe/future.png", 
                    "sequencer": "00000000000000000000000000001f9d000000000001e3b8", 
                    "storageDiagnostics": {"batchId": "8d2e6d6a-37c3-4d0d-ae7b-2b185e81e707"}
                    }, 
                "topic": "/subscriptions/21a7a4d3-3641-4382-95a8-85ae72399ceb/resourceGroups/gen3-compose-vprh/providers/Microsoft.Storage/storageAccounts/azgen3blobstorage", 
                "subject": "/blobServices/default/containers/azgen3blobstorage/blobs/AIRacingLeague.png", "event_type": "Microsoft.Storage.BlobCreated"
                }"""
     # Acquire the logger for a library (azure.storage.blob in this example)
    logger = logging.getLogger('azure.storage.blob')
    # # Set the desired logging level
    logger.setLevel(logging.DEBUG)
    # # Direct logging output to stdout. Without adding a handler,
    # # no logging output is captured.
    handler = logging.StreamHandler(stream=sys.stdout)
    logger.addHandler(handler)


    logger.info(f"Python EventGrid BlobEventTrigger1 processed an event: {result}")
    logger.info(f"Event view from EventGrid of event33 looks like:{event33}")

    data33 = json.loads(result)
    logger.info(f"after deserializing result data33 looks like {data33}")

    eventType = data33["event_type"]

    try:
        assert eventType == "Microsoft.Storage.BlobCreated"
    except:
        logger.warning("Exiting -- Event is not BlobCreated")
        


    url33 = data33["data"]["url"]
    logger.info(f"the url is {url33}")


    try:
        commons_url = "https://gen3playground.optum.com"
        gen3KeyID = "67179b32-f584-4a3b-b122-73d54ac2c65b"
        gen3KeySecret = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6ImZlbmNlX2tleV8yMDIwLTA5LTIyVDE2OjM2OjAwWiJ9.eyJwdXIiOiJhcGlfa2V5IiwiYXVkIjpbImRhdGEiLCJ1c2VyIiwiZmVuY2UiLCJvcGVuaWQiXSwic3ViIjoiMyIsImlzcyI6Imh0dHBzOi8vZ2VuM3BsYXlncm91bmQub3B0dW0uY29tL3VzZXIiLCJpYXQiOjE2MDUxMTMxODQsImV4cCI6MTYwNzcwNTE4NCwianRpIjoiNjcxNzliMzItZjU4NC00YTNiLWIxMjItNzNkNTRhYzJjNjViIiwiYXpwIjoiIn0.JBKC0mz2Gziq5q_sq184do8snFM2I-RpSqeBC359U4esfhtvDnZ4SrjuDAKBG-LM3YkE6L2Tz_aWjwXwediJzLjbCKm6PRu3HgMaY244CQZxoLnaLYNXWRrq7aHnY8qORNxhlAZVgQsNcWXu0SGk3mtDn8TY_d8Y7DIPhlaLQVAq18tfUHtg_9S5pz3XblWxAFHmz0Q_qdYDJwk5e3GseNI3_155XxP2UHURBhPfoWy8pQSU0LyKjwiL4VfbyAsS1KbWtS9K1NV0NzYUy3XdQrhJilkg97SrH03WVbLmEHQ1wVThPAA2jPF6jI7jf8nZpxwYQ_G69YtuoEiySeXp-g"
        connectString = "DefaultEndpointsProtocol=https;AccountName=azgen3blobstorage;AccountKey=0yzBB7W6H7Tz1wtmGHukXUuVA91YiYGn5anpPFgq4NoeccZ1rcqMgyaRCYwSYoZpUqMT0YJx1dWXTDjUQMltZQ==;EndpointSuffix=core.windows.net"
        results_file = "aaa.csv"
        mountPoint = "/tmp" 
    except :
        logger.critical("Critical Exception -- application settings not proper\n")
    
    #                                           0    1     2           3         4     5
    # split the fileURL since it is passed as https://site.azure.net/container/guid/filename
    try:
        thisContainer = url33.split('/',4)[3]  #container name
        thisGuid = url33.split('/',5)[4]
        thisBlob = url33.split('/',4)[4]  #guid/filename including trailing segments and extensions
        thisFileName = url33.split('/',5)[5]
    except:
        logger.critical(f"Critical Exception parsing url to container and blob name")
        exit

    logger.info(f"Python blob trigger function processed blob \n"
        f"GUID:      {thisGuid}\n"
        f"BLOB:      {thisBlob} \n"
        f"FILE:      {thisFileName}\n"
        f"CONTAINER: {thisContainer}\n\n"
        )

    try:
        assert thisContainer == "azgen3blobstorage"  #only process blobs in this container.
    except:
        logger.critical(f"Not processing blob in container {thisContainer}\n")
        exit
    else:
        logger.info(f"Continuing to process file {thisContainer}/{thisBlob}\n")

    # Get a blobClient object that points to the blob passed in.
    #logger.warning(f"The connection string is {base64.b64encode(connectString.encode('ascii'))}")
    try:
        blob_service_client = BlobServiceClient.from_connection_string(connectString)
        blob_client = blob_service_client.get_blob_client(container=thisContainer, blob=thisBlob)
    except:
        logger.critical(f"Error connecting to blob service or invalid blob not found\n -- {thisContainer}/{thisBlob} --\n")
        exit()
    else:
        logger.info(f"The existence of {thisBlob} blob_client.exists={blob_client.exists()}\n")
        logger.info(f"The size of the blob is {blob_client.get_blob_properties().size}\n")


# Download file in 10 Mbyte chunks and write to new file in azure file storage...
    

    try:
        #mynewblobfile = open(f"{mountPoint}/{thisGuid}/{thisBlob}", "wb")
        md5_object = hashlib.md5()
        fileOffset = 0
        numBytestRead = 0
        # set chunks to 10 MB in order to reduce HTTP turns, improve performance.  Could go higher if needed. 
        chunkSize = 10000000
        while fileOffset < blob_client.get_blob_properties().size :
            logger.info(f"fileoffset={fileOffset}")
            blobStream = blob_client.download_blob(offset=fileOffset, length=chunkSize)
            numBytestRead += blobStream.size
            chunk = blobStream.readall()
            md5_object.update(chunk)
            #mynewblobfile.write(chunk)
            fileOffset += chunkSize

        logger.info(f"Transferred {numBytestRead} bytes to the output file")
        #stream =  blob_client.download_blob()
        #data =  stream.readall()
        #mynewblobfile.write(data)
        #
    except Exception as thisNewException:
        logger.critical(f"Error Reading blob and calculating MD5 and writing local, error {thisNewException}\n")
        exit
    else:
        logger.info(f"downloaded {fileOffset/chunkSize} chunks of 10MB bytes from file at{url33}")
        #mynewblobfile.close()

    
    logger.info(f"commons_url = {commons_url}, gen3KeyID = {base64.b64encode(gen3KeyID.encode('ascii'))}, results_file = {results_file}, mountPoint {mountPoint}")
    md5_hash = md5_object.hexdigest()
    b64_hash = base64.b64encode(md5_object.digest()).decode('utf-8')
    logger.info(f"MD5 hash in long form is {md5_hash} and base64 hash of digest is {b64_hash}\n")

    try:
        res_filename=f"{mountPoint}/{thisContainer}/{results_file}"
        now = datetime.now()
        current_time = now.strftime("%Y/%m/%d %H:%M:%S")
        logger.info(f"opening results file at {res_filename}")
        b_file=open(res_filename,"a")
        b_file.write(f"Time,{current_time},Container,{thisContainer},Blob,{thisBlob},hexdigest,{md5_hash},base64hash,{b64_hash}\n")

    except: 
        logger.error(f"Error opening and writing results to {res_filename}\n")
    else:
        logger.info(f"wrote results file to {mountPoint}/azgen3blobstorage/{results_file}")
        logger.info(f"Time,{current_time},Container,{thisContainer},Blob,{thisBlob},hexdigest,{md5_hash},base64hash,{b64_hash}\n")
        b_file.close()

#    sas_token = generate_account_sas(
#        blob_service_client.account_name,
#        account_key=blob_service_client.credential.account_key,
#        resource_types=ResourceTypes(object=True),
#        permission=AccountSasPermissions(read=True,write=True,create=True),
#        expiry=datetime.utcnow() + timedelta(hours=1)
#    )
#
#    logger.warning(f"this is the sas token {sas_token}")
#    blob_service_client2 = BlobServiceClient(account_url="https://azgen3blobstorage.blob.core.windows.net/", credential=sas_token)
#    blob_client2 = blob_service_client2.get_blob_client(container="gen3-container", blob=f"guid-{thisBlob}/{thisBlob}")

    gen3Credentials = {}
    gen3Credentials['api_key'] = gen3KeySecret
    gen3Credentials['key_id'] = gen3KeyID
    auth = Gen3Auth(commons_url, refresh_token=gen3Credentials)
    indexConnection=Gen3Index(commons_url, auth_provider=auth)
    logging.warning(f"indexConnection = {indexConnection}")
    #logging.critical(f"Error with gen3connection{sys.exc_info()[0]}")
    try:
        testGuid = "fed285a2-5c22-4680-aa77-59fee6b8664b"
        indexRecord = indexConnection.get(thisGuid)
    except:
        logging.critical("Error connecting to commons URL")
    else:
        try:
            indexRev=indexRecord['rev']
            hashes={'md5': md5_hash }
            jurl=[ url33 ]
            logger.info(f"updating blank record {thisGuid} with hash {hashes} and size {numBytestRead}")
            indexConnection.update_blank(thisGuid, indexRev,hashes, numBytestRead)
            indexConnection.update_record(guid=thisGuid, urls=jurl)
        except:
            logger.critical(f"Error updating GUID {thisGuid} record in commons object {thisBlob}")   
        else:
            logger.info("Updated gen3 commons index with needful data.")




