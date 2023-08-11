function Get-BrowserArtifacts{
        <#
        .SYNOPSIS
            Gets browser artifacts.
        .DESCRIPTION
            Fetches Chrome, Edge, Firefox artifacts.
        .PARAMETER Quiet
            Disables terminal output.
        .PARAMETER Browser
            Identifies browser to retrieve artifacts from.
        .PARAMETER TargetUser
            Indicates which local user to retrieve browser data from.
        .PARAMETER Outpath
            Identifies output directory 
        .EXAMPLE
            Get-BrowserArtifacts
        .EXAMPLE
            Get-BrowserArtifacts -Browser Edge -TargetUser john 
        .NOTES
            ###################################################################
            Author:     @ms-smithch
            Version:    0.1a
            ###################################################################
            License:    GPLv3
            ###################################################################
        #>

        param (
            [Parameter][bool]
            $Quiet,
            [Parameter][string]
            $Browser,
            [Parameter][string]
            $Outpath = "$ENV:Temp\BrowserCollection\",
            [Parameter][string]
            $TargetUser,
            [Parameter][string]
            $AppDataPath = "$TargetUser\Appdata\"
        )

        $LogFile = (New-Item $Outpath + "collectionLog.txt").FullName

        #TODO: Works in test
        function Get-LocalUserFromAlias{
            [CmdletBinding()]
            param (
            [Parameter(Mandatory=$true)][string]
            $TargetUser
            )
            $UserProfiles = (Get-ChildItem "C:\Users" -ErrorAction Ignore).FullName
            foreach($i in $UserProfiles){
                $AADPlugin = (Get-ChildItem "$i\AppData\Local\Packages" -Filter "Microsoft.AAD.BrokerPlugin*" -ErrorAction Ignore).FullName
                $AADSettings = "$AADPlugin\Settings\settings.dat"
                if(Select-String -Pattern $TargetUser -Path $AADSettings -ErrorAction Ignore){ 
                    $i
                }
            }
        }

        #TODO: Test
        function Get-ValidEmail{
            [CmdletBinding()]
            param (
            [Parameter(Mandatory=$true)][string]
            $TargetUser
            )
            $isValid = $TargetUser -like '^([\w\.\-]+)@([\w\-]+)((\.(\w){2,3})+)$' ###looking for _@_._
            return $isValid
        }

        #TODO: Test
        function Get-AppdataPath{
            [CmdletBinding()]
            param (
                [Parameter(Mandatory=$true)][string]
                $SID
            )
            $AppdataKey = "REG:\\HKEY_USERS\$SID\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"
            $AppDataPath = Get-ChildItem $AppDataKey
            return $appDataPath
        }

        function Get-TargetArtifacts{
            [cmdletbinding()]
            param (        
                [Parameter(Mandatory=$true)][string]
                $SourcePath,
                [Parameter(Mandatory=$true)][array]
                $TargetArtifacts,
                [Parameter(Mandatory=$true)][array]
                $DestPath
            )

            foreach($i in $TargetArtifacts){
                try{
                    Write-Log "Fetching $i artifact"
                    Copy-Item -Path "$SourcePath\$i" -Destination $DestPath
                    Write-Log "$i artifact successfully gathered." -Level "Info"
                }
                catch{
                    Write-Log -Level 1 -Message "$i artifact not found"
                }
            }
        }


        #TODO: Test
        function Get-EdgeArtifacts{
            $outPath = (New-Item -ItemType Directory -Path $OutPath+"Edge\").FullName
            $dataPath = "$AppDataPath\Local\Microsoft\Edge\User Data\"
            $profiles = Get-ChildItem -Path $dataPath -Filter "Profile*"
            $profiles = $profiles.add("Default")
            $optArtifacts = {'load_statistics.db'}
            try{
                foreach($p in $profiles){
                    $profilePath = $dataPath+$p.Name
                    Write-Log -Level 0 -Message "Grabbing profile - $p"
                    Get-ChromiumArtifacts -SourcePath $profilePath -DestinationPath "$outPath\$p\" -OptArtifacts $optArtifacts
                }
            }
            catch {
                Write-Log -Level 2 "Error fetching Edge Artifacts"
            }
        }

        #TODO: Test
        function Get-ChromeArtifacts{   
            $outPath = (New-Item -ItemType Directory -Path $OutPath+"Chrome\").FullName
            $dataPath = "$AppDataPath\Local\Google\Chrome\User Data\"
            $profiles = Get-ChildItem -Path $dataPath -Filter "Profile*"
            $profiles = $profile.add("Default")
            try{
                foreach($p in $profiles){
                    $profilePath = "$dataPath/$p"
                    Write-Log -Level 0 -Message "Grabbing $p"
                    Get-ChromiumArtifacts -SourcePath $profilePath -DestinationPath "$destFolder/$p"
                }
            }
            catch {
                Write-Log -Level 2 "Error fetching Chrome Artifacts"
            }
        }

        function Get-ChromiumArtifacts{   
            [CmdletBinding()]
            param (
            [Parameter(Mandatory=$True)][string]
            $ProfilePath,
            [Parameter][array]
            $OptArtifacts
            )
            $targetArtifacts = {
                "history",
                "cookies",
                "cache",
                "web data",
                "extensions"
            }
            if ($OptArtifacts){
                foreach ($i in $OptArtifacts){
                    $targetArtifacts.Add($i)
                }
            }

            foreach ($a in $targetArtifacts){
                try {
                    Write-Log -Level 0 "Grabbing $a"
                    Copy-Item -Recurse -Path $ProfilePath+$a
                    }
                catch {
                    Write-Log -Level 2 "Error fetching $a Artifacts"
                }
            }
        }


        # #TODO: Identify if even necessary 
        # function Get-InternetExplorerArtifacts{
        #     $folder = $Outpath + "\InternetExplorer"
        #     $dataPath = "AppData\Local\Microsoft\Edge\User Data\Default"
        #     return $result
        # }

        #TODO: Identify Necessary Artifacts
        function Get-FirefoxArtifacts{
            [CmdletBinding()]
            param (
            [Parameter(Mandatory=$True)][string]
            $AppDataPath,
            [Parameter][string]
            $TargetUser
            )
            $outPath = (New-Item -ItemType Directory -Path $OutPath+"Firefox\").FullName
            $dataPath = "$AppData\Roaming\Mozilla\Firefox\Profiles\"
            $targetArtifacts = {
                "places.sqlite", 
                "formhistory.sqlite", 
                "downloads.sqlite", 
                "cookies.sqlite", 
                "search.sqlite",
                "signons.sqlite",
                "extensions.json"
            }
                $profiles = Get-ChildItem $dataPath
            try{
                foreach($p in $profiles){
                    New-Item -Path $Outpath+$p.Name -ItemType Directory
                    Get-TargetArtifacts -SourcePath $dataPath+$p -DestinationPath $outpath+$p `
                    -TargetArtifacts $targetArtifacts
                }
            }
            catch {
                Write-Log -Level 2 "Error fetching Firefox Artifacts"
            }

        }

        function Write-Log{
            [cmdletbinding()]
            param (        
                [Parameter(Mandatory=$true)][string]
                $Message,
                [Parameter][int]
                $Level = 0,
                [Parameter][string]
                $LogFile
            )
            $logLevel = @{
                0 = "Info"
                1 = "Warning"
                2 = "Error"
            }
            $now = Get-Date -Format "yyyyMMddHHmmSSZ" -AsUTC
            $loggedMessage = $LogLevel.$Level + "| $Now | $Message"
            Out-File -FilePath $LogFile -Append $loggedMessage
        }

        $ProfilePath = if($TargetUser -like "*@*"){
            Get-LocalUserFromAlias -TargetUser $TargetUser
            }else{
                "C:\Users\$TargetUser"
            }
        
        $AppDataPath = "$Profile\AppData"

        if (!(Get-Item $Outpath)){
            New-Item -Path $Outpath -ItemType Directory
        }

        switch ($browser) {
            condition { 
                Chrome {
                    Get-ChromeArtifacts -Outpath $Outpath -AppDataPath $AppDataPath
                }
                Firefox {
                    Get-FirefoxArtifacts -Outpath $Outpath -AppDataPath $AppDataPath
                }
                Edge {
                    Get-EdgeArtifacts -Outpath $Outpath -AppDataPath $AppDataPath
                }
                Default {
                    Get-FirefoxArtifacts -Outpath $Outpath -AppDataPath $AppDataPath
                    Get-EdgeArtifacts -Outpath $Outpath -AppDataPath $AppDataPath
                    Get-ChromeArtifacts -Outpath $Outpath -AppDataPath $AppDataPath
                }
            }
        }


        Write-Log -Message "Compressing browser artifacts for download"
        Compress-Archive -Path $Outpath -DestinationPath $Outpath+"BrowserArtifacts.zip" -Force
        Write-Log -Message "Archive available at " $Outpath+"BrowserArtifacts.zip"

        
}
