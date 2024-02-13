<#
    .DESCRIPTION
    Used for synchronizing the MDE Live Response library with a local folder path
    .PARAMETER SourcePath
    Identifies source folder path to synchronize with the library
    .EXAMPLE
    Invoke-LiveResponseSync.ps1 -SourcePath "D:\source\libraryfiles" 
#>
param(
    [Parameter(Mandatory=$True)]
    [string]
    $SourcePath
)
Install-Module Az.Accounts
Connect-AzAccount
$token = (Get-AzAccessToken -ResourceUrl 'https://api.securitycenter.microsoft.com').token
$Uri = 'https://api.securitycenter.microsoft.com/api/libraryfiles'
$Headers = @{
    'Authorization'= 'Bearer ' + $Token
    'Connection'="None"
    'Accept'='*/*'
    'Accept-Encoding'= "None"
}

function Add-LiveResponseFile(){
    param (
        [System.IO.FileInfo]$File
    )
    $AddRequest = @{
        'Uri' = $Uri
        'Method' = 'Post'
        'Headers' = $Headers
        'Form' = @{
            'file-name' = $File.Name
            'Description' =  ''
            'OverrideIfExists' = 'true'
            'HasParameters' = ''
            'ParametersDescription' = ''
            'File' = Get-Item -Path $File.FullName
        }
    }
    if ($File -like '*.ps1'){
        $HelpContent = Get-Help $File.FullName
        $AddRequest.Form.HasParameters = [bool]($HelpContent.parameters)
        $AddRequest.Form.ParametersDescription = if ([bool]$HelpContent.parameters){ ($HelpContent.examples.example[0] | Out-String).trim()}
        $AddRequest.Form.Description = ($HelpContent.Description | Out-String).trim()
    }
    try {
        $Response = Invoke-RestMethod @AddRequest
        return $Response
    }
    catch {
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
    }
}

function Remove-LiveResponseFile(){
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $FileName
    )
    $DeleteRequest = @{
        Uri = $Uri+'/'+$FileName
        Method = 'Delete'
        Headers = $Headers
    }
    try{
        $Response = Invoke-RestMethod @DeleteRequest
        return $Response
    }
    catch {
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
    }
}

function Get-LiveResponseLibrary(){
    $GetRequest = @{
        Uri = $Uri
        Method = 'Get'
        Headers = $Headers
    }
    try{
        $Response = (Invoke-RestMethod @GetRequest).Value
        return $Response
    }
    catch{
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
    }
}

function main(){
    param (
        [string]$SourcePath
    )
    $Files = Get-ChildItem -File -Path $SourcePath
    $Library = Get-LiveResponseLibrary

    $Count = 0
    $StopWatch = New-Object -TypeName 'System.Diagnostics.Stopwatch'
    $StopWatch.start()
    foreach ($File in $Files){
        $Hash = Get-Filehash -Algorithm SHA256 -Path $File.FullName 
        if ($Hash -in $Library.SHA256){
            Write-Host "File $($File.Name) already uploaded, no changes"
        }
        else{
            Add-LiveResponseFile -File $File 
            Write-Host "File $($File.Name) uploaded"
        }
        $Count += 1
        # Handling rate limiting, tested in demo tenant and rate limit appears lower than the documented 100 requests/60s
        if ($count%5 -eq 0 -and $StopWatch.Elapsed.Seconds%60 -gt 0){
            Write-Host "Sleeping..."
            Start-Sleep (60 - $StopWatch.Elapsed.Seconds%60 )
        }
    }
    $StopWatch.Stop()
    $FilesToDelete = (Compare-Object $Files.Name $Library.fileName | Where-Object {$_.sideindicator -eq '=>'}).InputObject
    foreach ($File in $FilesToDelete){
        Remove-LiveResponseFile -FileName $File
    }
}

main -SourcePath $SourcePath

