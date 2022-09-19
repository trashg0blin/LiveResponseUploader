import LiveResponseUploader
import MSALAuthenticator
import json 
import os

params = json.load(open("parameters.json"))

# def main():
files = os.listdir(params["sourcePath"])
token = MSALAuthenticator.authToAz(params)
# Loop to print each filename separately
for file in files:
    LiveResponseUploader.uploadToLiveResponse(file,token=token)
