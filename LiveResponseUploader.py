from requests import post
import json
import os
import binascii
import logging

params = json.load(open("parameters.json"))

def encode_multipart_formdata(fields):
    boundary = binascii.hexlify(os.urandom(8)).decode('ascii')

    body = (
        "".join("--------------------------%s\n"
                "Content-Disposition: form-data; name=\"%s\""
                "\n"
                "%s\n" % (boundary, field, value)
                for field, value in fields.items()) +
        "--------------------------%s--\n" % boundary
    )

    content_type = "multipart/form-data;boundary=--------------------------------%s" % boundary
    return body, content_type

def uploadToLiveResponse(file,desc="test",paramdesc="",override=True,token=''):
    if not token:
        logging.error("No authentication token available")
        exit()
    
    url = 'https://api.securitycenter.microsoft.com/api/libraryfiles'
    filePath = params["sourcePath"] + '/' + file
    rawFile = open(filePath,"rt").read()

    requestData={
        "file": "; filename=\"%s\" \nContent-Type: application/octet-stream\n\n%s" % (file, rawFile),
        "Description": desc,
        "OverrideIfExists": 'true'
    }
    requestData,contentType = encode_multipart_formdata(requestData)

    requestHeaders = {
        'Authorization': 'Bearer ' + token,
        'Content-Type': contentType,
        'Connection':None,
        'Accept':'*/*',
        'Accept-Encoding':None,
        'Proxies':"http://localhost:8080",
        'Verify':"false"
    }
    
    response = post(
        url,
        headers=requestHeaders,
        data=requestData
    )
    if response.status_code == 200:
        logging.info("File uploaded")
    if response.status_code == 400:
        logging.error("Bad request")
    if response.status_code == 401:
        logging.error("Unauthorized request")
    if response.status_code == 500:
        logging.error("wasn't me")

    print(response._content) 

    return response

