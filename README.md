# MDE Live Response Library DevOps Pipeline Tool

This module combines the power of DevOps tooling with available API's to increase the manageability of the Microsoft Defender for Endpoint Live Response Library.

To populate required data fields, each script that is created within a target directory for synchronization must have a manifest file name as script.ext.json, where script.ext is the name of of your script. The JSON file serves as a metadata file that is referenced by the module at upload time and is structured as
```
{
    "Description":"Description goes here",
    "HasParameters":false,
    "ParametersDescription":"Parameter description goes here"
}
```
This module expects the git repository to be structured as:
/RepositoryRoot
./Scripts
../SomeScript.sh
../SomeScript.sh.json

## Requirements
Declared Environment Variables
  - CLIENT = Azure AD Client ID
  - AUTHORITY = Azure AD Tenant Sign in URL (https://login.microsoftonline.com/<Tenant ID\>)
  - SECRET = Azure AD Client Secret
  - LOG_NAME = Output log filename
  - LOG_LEVEL = Python Logging level

## Usage
python -m LiveResponsePipeline /path/to/source/directory/of/repository

