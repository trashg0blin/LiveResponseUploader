import requests
import json
import logging

params = json.load(open("parameters.json"))
url = 'https://api.securitycenter.microsoft.com/api/libraryfiles'
    
def fetch_library_objects(token):
    requestHeaders = {
    'Authorization': 'Bearer ' + token,
    'Connection':None,
    'Accept':'*/*',
    'Accept-Encoding':None}
    response = requests.get(url,headers=requestHeaders)
    data = response.json().value["sha256"]
    return data


def uploadToLiveResponse(file,desc="test",paramdesc="",override=True,token=''):
    if not token:
        logging.error("No authentication token available")
        exit()
    
    filePath = params["sourcePath"] + '/' + file
    file = {"file":(file,open(filePath,"rb"),'application-type/octet-stream')}
    payload = {'file-name':file,
               'Description':desc,
               'OverrideIfExists':'true'}
    requestHeaders = {
    'Authorization': 'Bearer ' + token,
    'Connection':None,
    'Accept':'*/*',
    'Accept-Encoding':None}
    
    req = requests.post(
        url,
        headers=requestHeaders,
        data=payload,
        files=file
    )
    if req.status_code == 200:
        logging.info("File uploaded")
    if req.status_code == 400:
        logging.error("Bad request")
    if req.status_code == 401:
        logging.error("Unauthorized request")
    if req.status_code == 500:
        logging.error("wasn't me")

    print(req._content) 

    return req

