import json
import requests

URL = 'https://api.securitycenter.microsoft.com/api/libraryfiles'

def fetch_library_objects(token):
    """Retrieves objects from the live response library

    Args:
        token (str): Authentication Token

    Returns:
        list: list of strings
    """
    request_headers = {
    'Authorization': 'Bearer ' + token,
    'Connection':None,
    'Accept':'*/*',
    'Accept-Encoding':None}

    response = requests.get(URL,headers=request_headers,timeout=30)
    library = response.json()['value']
    hashes = []
    for item in library:
        hashes.append(item['sha256'])
    return hashes

def retrieve_manifest(file_path):
    """Retrieves the metadata manifest for a script

    Args:
        file_path (str)): File path 

    Returns:
        dict: dictionary of file metadata values.
    """
    manifest_path = str(file_path + '.json')
    with open(manifest_path,encoding="utf-8") as m:
        manifest = json.load(m)
    return manifest

def upload_to_live_response(file,file_path,token,description="",param_description="",
                            has_params=False):
    """Uploads a file to the live response library

    Args:
        file (str): File Name
        description (str, optional): File description. Defaults to "".
        param_description (str, optional): Parameter description. Defaults to "".
        has_params (bool, optional): Script has parameters. Defaults to False.
        token (str, optional): Authentication token. Defaults to ''.

    Returns:
        _type_: _description_
    """
    payload = {'file-name':file,
                'Description':description,
                'OverrideIfExists':'true',
                'HasParameters':str(has_params),
                'ParametersDescription':param_description}
    request_headers = {
    'Authorization': 'Bearer ' + token,
    'Connection':None,
    'Accept':'*/*',
    'Accept-Encoding':None}
    with open(file_path,"rb") as raw_file:
        file = {"file":(file,raw_file,'application-type/octet-stream')}
        requests.post(
            URL,
            headers=request_headers,
            data=payload,
            files=file,
            timeout=30)
