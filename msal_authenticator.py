import logging
from msal import ConfidentialClientApplication


def auth_to_az(params):
    """Authenticates to Azure AD.

    Args:
        params (dict): Parameters used in auth.

    Returns:
        str: token used in authentication
    """
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

    return result['access_token']
