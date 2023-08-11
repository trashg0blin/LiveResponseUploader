import LiveResponseUploader
import MSALAuthenticator
import json 
import os
from hashlib import sha256

params = json.load(open("parameters.json"))

# def main():
files = os.listdir(params["sourcePath"])
token = MSALAuthenticator.authToAz(params)
# Loop to print each filename separately
library = LiveResponseUploader.fetch_library_objects()
for file in files:
    fileHash = sha256(open(file,'rb')).hexdigest
    if fileHash in library:
        print("File already uploaded, no changes")
    else:
        LiveResponseUploader.uploadToLiveResponse(file,token=token)
