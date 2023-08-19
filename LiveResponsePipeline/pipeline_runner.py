import logging
import os
import sys

from LiveResponsePipeline import live_response_uploader
from LiveResponsePipeline import msal_authenticator
from LiveResponsePipeline import utils

def run_pipeline(source_path):

    files = os.listdir(source_path)
    token = msal_authenticator.auth_to_az()
    if not token:
        logging.error("No authentication token available")
        sys.exit()

    library = live_response_uploader.fetch_library_objects(token)

    for file in files:
        file_path = source_path + '/' + file
        file_hash = utils.sha256sum(file_path)
        if file_hash in library:
            logging.info("File %s//sha256:%s already uploaded, no changes",file,file_hash)
        elif 'json' in file:
            continue
        else:
            manifest = live_response_uploader.retrieve_manifest(file_path)
            live_response_uploader.upload_to_live_response(
                file=file,
                file_path=file_path,
                token=token,
                description=manifest['Description'],
                param_description=manifest['ParametersDescription'],
                has_params=manifest['HasParameters'])
            logging.info("File %s//sha256:%s uploaded",file,file_hash)
