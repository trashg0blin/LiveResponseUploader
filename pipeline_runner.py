import json
import logging
import os
import sys
import live_response_uploader
import msal_authenticator
from utils import sha256sum

with open("parameters.json",encoding="utf-8") as p:
    Params = json.load(p)
SourcePath =  Params["sourcePath"]
logging.basicConfig(filename='pipeline.log', encoding='utf-8',level=Params["loglevel"])

Files = os.listdir(SourcePath)
Token = msal_authenticator.auth_to_az(Params)
if not Token:
    logging.error("No authentication token available")
    sys.exit()

Library = live_response_uploader.fetch_library_objects(Token)

for File in Files:
    File_Path = SourcePath + '/' + File
    File_Hash = sha256sum(File_Path)
    if File_Hash in Library:
        logging.info("File %s//sha256:%s already uploaded, no changes",File,File_Hash)
    elif 'json' in File:
        continue
    else:
        manifest = live_response_uploader.retrieve_manifest(File_Path)
        live_response_uploader.upload_to_live_response(
            file=File,
            file_path=File_Path,
            token=Token,
            description=manifest['Description'],
            param_description=manifest['ParametersDescription'],
            has_params=manifest['HasParameters'])
