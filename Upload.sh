#!/bin/sh
#Regex based off of https://github.com/PoshCode/PowerShellPracticeAndStyle/blob/master/Style-Guide/Documentation-and-Comments.md#doc-01-write-comment-based-help




authstring='grant_type=client_credentials&client_id=57e52965-9b03-4926-bf0b-46c73ed9f50b&client_secret=BgV8Q~LSp7JXCf4jmvio2IrjdidzwspDZIJ-Sdg3&resource=https%3A%2F%2Fapi.securitycenter.microsoft.com%2f' 
token=(curl -X POST -d $authstring https://login.microsoftonline.com/bbd10e79-3517-4c68-94dc-b722048636f0/oauth2/token) | sed -n 's/^[[:space:]]*"access_token": "\(.*\)",/\1/p'
curl -X POST https://api.securitycenter.microsoft.com/api/libraryfiles -H "Authorization: Bearer $token" -F "file=@Get-BrowserArtifacts.ps1" -F "ParametersDescription=test" -F "HasParameters=true" -F "OverrideIfExists=true" -F "Description=testdescription"

