from msal import ConfidentialClientApplication
import json
import logging

params = json.load(open("parameters.json"))

def authToAz(params):
    app = ConfidentialClientApplication(
        params['client'],
        authority=params['tenant'],
        client_credential=params['secret']
        )
    result = None
    # check cache
    result = app.acquire_token_silent(scopes=params["scope"], account=None)
    if not result:
        logging.info("No suitable token exists in cache. Let's get a new one from AAD.")
        result = app.acquire_token_for_client(scopes=params["scope"])

    if "access_token" in result:
        print(result["token_type"])
    else:
        print(result.get("error"))
        print(result.get("error_description"))
        print(result.get("correlation_id")) 

    return result['access_token']