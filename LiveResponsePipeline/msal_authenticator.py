import logging
from os import environ

from msal import ConfidentialClientApplication

scope = ["https://api.securitycenter.microsoft.com/.default"]

def auth_to_az():
    """Authenticates to Azure AD.

    Args:
        params (dict): Parameters used in auth.

    Returns:
        str: token used in authentication
    """
    app = ConfidentialClientApplication(
        environ['CLIENT'],
        authority=environ['AUTHORITY'],
        client_credential=environ['SECRET']
        )
    result = None

    result = app.acquire_token_silent(scopes=scope, account=None)
    if not result:
        logging.info("No suitable token exists in cache. Let's get a new one from AAD.")
        result = app.acquire_token_for_client(scopes=scope)

    return result['access_token']
