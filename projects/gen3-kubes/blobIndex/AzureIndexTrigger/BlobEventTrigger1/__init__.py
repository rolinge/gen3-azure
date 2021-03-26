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


def main(blobEventGen3: func.EventGridEvent):
    jsonResult = json.dumps({
        'id': blobEventGen3.id,
        'data': blobEventGen3.get_json(),
        'topic': blobEventGen3.topic,
        'subject': blobEventGen3.subject,
        'event_type': blobEventGen3.event_type,
    })

    # Acquire the logger for a library (azure.storage.blob in this example)
    logger = logging.getLogger('azure.storage.blob')

    # # Set the desired logging level
    logger.setLevel(logging.DEBUG)

    # # Direct logging output to stdout. Without adding a handler no logging output is captured.
    handler = logging.StreamHandler(stream=sys.stdout)
    logger.addHandler(handler)

    logger.info(f"Python EventGrid BlobEventTrigger1 processed an event: {jsonResult}")
    logger.info(f"Event view from EventGrid of blobEventGen3 looks like:{blobEventGen3}")

    data33 = json.loads(jsonResult)
    logger.info(f"after deserializing jsonResult data33 looks like {data33}")

    eventType = data33["event_type"]

    try:
        assert eventType == "Microsoft.Storage.BlobCreated"
    except:
        logger.critical("Critical Exception -- Exiting -- Event is not BlobCreated")
        return

    url33 = data33["data"]["url"]
    logger.info(f"the url is {url33}")

    logger.info(f"Checking to see that application settings are proper")
    try:
        commons_url = os.environ['COMMONS_URL']
        gen3KeyID = os.environ['gen3KeyID']
        gen3KeySecret = os.environ['gen3KeySecret']
        connectString = os.environ['StorageaccountConnectString']
        results_file = os.environ['RESULTS_FILE'] 
        mountPoint = os.environ['MOUNT_POINT'] 
        logger.info(f"Application settings are proper")
    except :
        logger.critical("Critical Exception -- application settings not proper\n")
        return
    
    #                                           0    1     2           3         4     5
    # split the fileURL since it is passed as https://site.azure.net/container/guid/filename
    try:
        split_url = url33.split('/')
        thisContainer = split_url[3]  #container name
        thisGuid = split_url[4]
        thisBlob = split_url[4] + '/' + split_url[5]  #guid/filename including trailing segments and extensions
        thisFileName = split_url[5]
    except:
        logger.critical(f"Critical Exception -- parsing url to container and blob name")
        return

    logger.info(f"Python blob trigger function processed blob \n"
        f"GUID:      {thisGuid}\n"
        f"BLOB:      {thisBlob} \n"
        f"FILE:      {thisFileName}\n"
        f"CONTAINER: {thisContainer}\n\n"
        )


    # Only processing file that land in the container named azgen3blobstorage
    try:
        assert thisContainer == "azgen3blobstorage"  #only process blobs in this container.
    except:
        logger.critical(f"Critical Exception -- Not processing blob in container {thisContainer}\n")
        return
    else:
        logger.info(f"Continuing to process file {thisContainer}/{thisBlob}\n")


    # Get a blobClient object that points to the blob passed in.
    try:
        #logger.info(f"The connection string is {base64.b64encode(connectString.encode('ascii'))}")
        blob_service_client = BlobServiceClient.from_connection_string(connectString)
        blob_client = blob_service_client.get_blob_client(container=thisContainer, blob=thisBlob)
    except:
        logger.critical(f"Critical Exception -- error connecting to blob service or invalid blob not found\n -- {thisContainer}/{thisBlob} --\n")
        return True
    else:
        logger.info(f"The Azure reported size of the blob is {blob_client.get_blob_properties().size}\n")


    # Download file in 10 Mbyte chunks and write to new file in azure file storage...
    logger.info(f"Downloading file in 10 Mbyte chunks")
    #mynewblobfile = open(f"{mountPoint}/{thisGuid}/{thisBlob}", "wb")
    md5_object = hashlib.md5()
    fileOffset = 0
    numBytesRead = 0
    # set chunks to 10 MB in order to reduce HTTP turns, improve performance.  Could go higher if needed. 
    chunkSize = 10000000
    
    try: 
        while fileOffset < blob_client.get_blob_properties().size :
            logger.info(f"fileoffset={fileOffset}")
            blobStream = blob_client.download_blob(offset=fileOffset, length=chunkSize)
            numBytesRead += blobStream.size
            chunk = blobStream.readall()
            md5_object.update(chunk)
            #mynewblobfile.write(chunk)
            fileOffset += chunkSize

        logger.info(f"Transferred {numBytesRead} bytes to the output file")
        #stream =  blob_client.download_blob()
        #data =  stream.readall()
        #mynewblobfile.write(data)
        #
    except Exception as thisNewException:
        logger.critical(f"Critical Exception -- error Reading blob and calculating MD5 and writing local, error {thisNewException}\n")
        return
    else:
        logger.info(f"downloaded {fileOffset/chunkSize} chunks of 10MB bytes from file at {url33}\n")
        #mynewblobfile.close()

    
    logger.info(f"commons_url = {commons_url}, gen3KeyID = {base64.b64encode(gen3KeyID.encode('ascii'))}, results_file = {results_file}, mountPoint {mountPoint}")
    
   
    md5_hash = md5_object.hexdigest()
    b64_hash = base64.b64encode(md5_object.digest()).decode('utf-8')
    logger.info(f"MD5 hash in long form is {md5_hash} and base64 hash of digest is {b64_hash}\n")

    res_filename=f"{mountPoint}/{thisContainer}/{results_file}"
    now = datetime.now()
    current_time = now.strftime("%Y/%m/%d %H:%M:%S")
    logger.info(f"opening results file at {res_filename}")

    try:
        b_file=open(res_filename,"a")
        b_file.write(f"Time,{current_time},Container,{thisContainer},Blob,{thisBlob},hexdigest,{md5_hash},base64hash,{b64_hash}\n")

    except: 
        logger.critical(f"Critical Exception -- error opening and writing results to {res_filename}")
    else:
        logger.info(f"wrote results file to {mountPoint}/azgen3blobstorage/{results_file}")
        logger.info(f"Time,{current_time},Container,{thisContainer},Blob,{thisBlob},hexdigest,{md5_hash},base64hash,{b64_hash}\n")
        b_file.close()


    gen3Credentials = {}
    gen3Credentials['api_key'] = gen3KeySecret
    gen3Credentials['key_id'] = gen3KeyID
    auth = Gen3Auth(commons_url, refresh_token=gen3Credentials)
    indexConnection=Gen3Index(commons_url, auth_provider=auth)
    logger.info(f"indexConnection = {indexConnection}")
    #logging.critical(f"Error with gen3connection{sys.exc_info()[0]}")


    try:
        indexRecord = indexConnection.get(thisGuid)
    except Exception as thisNewException:
        logging.critical(f"Critical Exception -- error connecting to commons URL, error is {thisNewException}")
    else:
        try:
            indexRev=indexRecord['rev']
            hashes={'md5': md5_hash }
            jurl=[ url33 ]
            logger.info(f"updating blank record {thisGuid} with hash {hashes} and size {numBytesRead}")
            indexConnection.update_blank(thisGuid, indexRev,hashes, numBytesRead)
            indexConnection.update_record(guid=thisGuid, urls=jurl)
        except:
            logger.critical(f"Critical Exception -- error updating GUID {thisGuid} record in commons object {thisBlob}")   
        else:
            logger.info("Updated gen3 commons index with needful data.")

    return


