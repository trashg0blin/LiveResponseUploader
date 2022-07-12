import re
from msal import ConfidentialClientApplication
import json
import os
import logging
from requests import post
from requests.auth import AuthBase

config = json.load(open("parameters.json"))

class TokenAuth(AuthBase):
    """Implements a custom authentication scheme."""

    def __init__(self, token):
        self.token = token
    def __call__(self, r):
        """Attach an API token to a custom auth header."""
        r.headers['Authentication'] = f'Bearer {self.token}'  # Python 3.6+
        return r

def authToAz(config):
    
    app = ConfidentialClientApplication(config['client'],authority=config['tenant'],client_credential=config['secret'])

    # The pattern to acquire a token looks like this.
    result = None

    # First, the code looks up a token from the cache.
    # Because we're looking for a token for the current app, not for a user,
    # use None for the account parameter.
    result = app.acquire_token_silent(config["scope"], account=None)

    if not result:
        logging.info("No suitable token exists in cache. Let's get a new one from AAD.")
        result = app.acquire_token_for_client(scopes=config["scope"])

    if "access_token" in result:
        # Call a protected API with the access token.
        print(result["token_type"])
    else:
        print(result.get("error"))
        print(result.get("error_description"))
        print(result.get("correlation_id"))  # You might need this when reporting a bug.

    return result

def uploadToLiveResponse(file,desc="",paramdesc="",override=""):
    rawFile = open(file)
    token = authToAz

    r = post(

        'https://api.securitycenter.microsoft.com/api/libraryfiles',
        auth=TokenAuth(token),
        data={
            "File": rawFile,
            "Description": desc,
            "ParametersDescription": paramdesc,
            "OverrideIfExists": override
        }
    )

def filePaths(directory):
    return [os.path.join(directory, file) for file in os.listdir(directory)]

# def main():
files = filePaths(config["sourcePath"])

# Loop to print each filename separately
for file in files:
    uploadToLiveResponse(file)
