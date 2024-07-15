<#
.SYNOPSIS
Installs the Sensing SDK.

.DESCRIPTION
This script downloads and installs the Sensing SDK components. You can specify a particular version or the latest version will be installed by default.

.PARAMETER Verbose
Display verbose

.PARAMETER version
Specifies the version of the Sensing SDK to be installed. Default is 'latest'.

.PARAMETER user
It used to be the flag to switch .zip version and .msi version of the package. Deprecated as of v24.05.05.

.PARAMETER installPath
The installation path for the Sensing SDK. Default is the sensing-dev-installer directory in the user's LOCALAPPDATA.

.PARAMETER InstallOpenCV
If set, the script will also install OpenCV. This is not done by default.

.EXAMPLE
PS C:\> .\installer.ps1 -version 'v24.05.06'

This example demonstrates how to run the script with custom version

.EXAMPLE
PS C:\> .\installer.ps1 -InstallOpenCV

This example demonstrates how to run the script with the default settings and includes the installation of OpenCV.

.NOTES
Ensure that you have the necessary permissions to install software and write to the specified directories.

.LINK
https://sensing-dev.github.io/doc/startup-guide/windows/index.html

#>

[cmdletbinding()]
param(
  [string]$version,
  [string]$user,
  [string]$installPath,
  [switch]$InstallOpenCV = $false
)

$installerName = "sensing-dev"
$repositoryName = "Sensing-Dev/sensing-dev-installer"

# function Test-WritePermission {
#   param (
#     [string]$path,
#     [string]$user = "$env:USERDOMAIN\$env:USERNAME"
#   )

#   $writeAllowed = $false
#   $acl = Get-Acl $path

#   foreach ($access in $acl.Access) {
#     if ($access.IdentityReference -eq $user) {
#       if (
#         ( 
#           $access.FileSystemRights -match "Write" -or 
#           $access.FileSystemRights -match "FullControl"
#         ) -and 
#         $access.AccessControlType -eq "Allow") {
#         Write-Host "$user has write permission for $path"
#         $writeAllowed = $true
#         break
#       }
#     }
#   }

#   if (-not $writeAllowed) {
#     Write-Host "$user needs write permission for $path"
#   }

#   return $writeAllowed
# }

function Get-LatestVersion {
  param (
  )

  $RepoApiUrl = "https://api.github.com/repos/$repositoryName/releases/latest"

  try {
    $response = Invoke-RestMethod -Uri $RepoApiUrl -Headers @{Accept = "application/vnd.github.v3+json" }
    $latestVersion = $response.tag_name

    if ($latestVersion) {
      return $latestVersion
    }
    else {
      Write-Error "Latest version not found."
      exit 1
    }
  }
  catch {
    Write-Error "Error fetching the latest version: $_"
    exit 1
  }
}

function DownloadComponents(){
  param(
    [switch]$InstallOpenCV
  )
  begin {
    # Clear-Host
    $script:Date = Get-Date -Format "dddd MM/dd/yyyy HH:mm K"
    Write-Host "--------------------------------------" -ForegroundColor Green
    Write-Host " Start Download SDK Components $script:Date" -ForegroundColor Green
  }
  process {
    $tempWorkDir = Join-Path -Path $env:TEMP -ChildPath $installerName
    if (-not (Test-Path $tempWorkDir)) {
        New-Item -ItemType Directory -Path $tempWorkDir | Out-Null
    }
  }
}

function CheckComponentHash(){
  param(
    [string]$compName,
    [string]$archivePath,
    [string]$expectedHash
  )
  if (Test-Path "$archivePath") {
    try {

        $fileStream = [System.IO.File]::OpenRead($archivePath)
        $hashAlgorithm = [System.Security.Cryptography.HashAlgorithm]::Create("SHA256")
        $computedHashBytes = $hashAlgorithm.ComputeHash($fileStream)
        $fileStream.Close()
        
        $computedHash = [BitConverter]::ToString($computedHashBytes) -replace "-", ""

        # ハッシュ値を比較
        if ($computedHash -eq $expectedHash) {
            Write-Output "The component $compName has been downloaded successfully and the hash matches."
        } else {
            throw "The hash of the downloaded $compName does not match the expected hash."
        }
    } catch {
        throw "Failed to compute or compare the hash of the downloaded $compName."
    }
  } else {
    throw "The component $compName was not downloaded."
  }
}

# function Install-ZIP(){
#   param (
#     [string] $installPath,
#     [string] $installerName,
#     [string] $installerPostfixName,
#     [string] $versionNum,
#     # exit code
#     [Parameter(Mandatory = $false)]
#     [int32] $ProcessExit = 0
#   )
#   begin {
#     # Clear-Host
#     $script:Date = Get-Date -Format "dddd MM/dd/yyyy HH:mm K"
#     Write-Host "--------------------------------------" -ForegroundColor Green
#     Write-Host " Start Installation Zip $script:Date" -ForegroundColor Green
#   }
#   process {
#     if(-not $LocalInstaller)
#     {
#       $tempZipPath = "${env:TEMP}\${installerName}.zip"
#       Invoke-WebRequest -Uri $script:Url -OutFile $tempZipPath -Verbose
#     }
#     else{
#       $tempZipPath = $LocalInstaller
#     }

#     Add-Type -AssemblyName System.IO.Compression.FileSystem

#     $tempExtractionPath = "$installPath\_tempExtraction"
#     # Create the temporary extraction directory if it doesn't exist
#     if (-not (Test-Path $tempExtractionPath)) {
#       New-Item -Path $tempExtractionPath -ItemType Directory
#     }
#     # Attempt to extract to the temporary extraction directory
#     try {
#       Expand-Archive -Path $tempZipPath -DestinationPath $tempExtractionPath 
#       Start-Sleep -Seconds 5
#       Get-ChildItem -Path $tempExtractionPath
#       # If extraction is successful, replace the old contents with the new
#       $installPath = "$installPath\$installerName"
#       if (Test-Path -Path ${installPath}) {
#         Get-ChildItem -Path $installPath -Recurse | Remove-Item -Force -Recurse
#       }
#       else {
#         New-Item -Path $installPath -ItemType Directory
#       }
#       Move-Item -Path "$tempExtractionPath\${installerName}${installerPostfixName}-${versionNum}-win64\*" -Destination $installPath -Force

#       # Cleanup the temporary extraction directory
#       Remove-Item -Path $tempExtractionPath -Force -Recurse
#     }
#     catch {
#       $ProcessExit = 1      
#     }    
#     # Optionally delete the ZIP file after extraction
#     Remove-Item -Path $tempZipPath -Force
#   }
#   end {

#     if ($ProcessExit -eq 0) {
#         Write-Host " Success installing Zip  at $script:Date" -ForegroundColor Green
#         Write-Host "--------------------------------------" -ForegroundColor Green
#     }
#     else {
#         # Optional: Cleanup the temporary extraction directory
#         Remove-Item -Path $tempExtractionPath -Force -Recurse
#         Write-Error "Extraction failed. Original contents remain unchanged."
#         Write-Error " $ProcessExit Failed installing Zip  at $script:Date"
#         Write-Host "--------------------------------------" -ForegroundColor Green
#         exit $ProcessExit
#     }
#     return $ProcessExit
#   }
# }

# function Install-MSI(){
#   param (
#     [string] $installPath,
#     [string] $installerName,
#     # exit code
#     [Parameter(Mandatory = $false)]
#     [int32] $ProcessExit = 0
#   )
#   begin {
#     # Clear-Host
#     $script:Date = Get-Date -Format "dddd MM/dd/yyyy HH:mm K"
#     Write-Host "--------------------------------------" -ForegroundColor Green
#     Write-Host " Start Installation MSI $script:Date" -ForegroundColor Green
#   }
#   process {

#     $installPath = "$installPath\$installerName"

#     # Download MSI to a temp location
#     if(-not $LocalInstaller){

#       $tempMsiPath = "${env:TEMP}\${installerName}.msi"
#       Invoke-WebRequest -Uri $script:Url -OutFile $tempMsiPath -Verbose
#     }
#     else{
#       $tempMsiPath = $LocalInstaller
#     }

#     $log = "${env:TEMP}\${installerName}__install.log"
#     $hasAccess = Test-WritePermission -user $user -path $installPath

#     if($hasAccess){
#       Start-Process -Wait -FilePath "msiexec.exe" -ArgumentList "/i ${tempMsiPath} INSTALL_ROOT=${installPath} /qb /l*v ${log}" 
#     }
#     else {
#       Start-Process -Wait -FilePath "msiexec.exe" -ArgumentList "/i ${tempMsiPath} INSTALL_ROOT=${installPath} /qb /l*v ${log}" -Verb RunAs
#     }

#     # Check if the process started and finished successfully
#     if ($?) {
#       Write-Host "${installerName} installed at ${installPath}. See detailed log here ${log} "
#     }
#     else {
#       $ProcessExit = 1         
#     }
#     # Optionally delete the MSI file after extraction
#     Remove-Item -Path $tempMsiPath -Force
#   }
#   end {

#     if ($ProcessExit -eq 0) {
#         Write-Host " Success installing MSI  at $script:Date" -ForegroundColor Green
#         Write-Host "--------------------------------------" -ForegroundColor Green
#     }
#     else {
#         Write-Error "The ${installerName} installation encountered an error. See detailed log here ${log}"     
#         Write-Error " $BuildExit Failed installing MSI  at $script:Date"
#         Write-Host "--------------------------------------" -ForegroundColor Green
#         exit $ProcessExit
#     }
#     return $ProcessExit
#   }
# }

# function Set-InstallerEnvironment(){
#   param (
#     [string] $installPath,
#     [string] $installerName
#   )
#   $installPath
#   if (Test-Path -Path ${installPath}) {
#     $relativeScriptPath = "tools\Env.ps1"
#     # Run the .ps1 file from the installed package
#     $ps1ScriptPath = Join-Path -Path $installPath\$installerName -ChildPath $relativeScriptPath
#     Write-Host "ps1ScriptPath = $ps1ScriptPath"
#     if (Test-Path -Path $ps1ScriptPath -PathType Leaf) {
#       $outputEnvScript = & $ps1ScriptPath -InstallOpenCV:$InstallOpenCV
#       Write-Host $outputEnvScript
#     }
#     else {
#       Write-Error "Script at $relativeScriptPath not found in the installation path!"
#       exit 1
#     }
#   } 
# }

function Invoke-Script {
  param(
        # exit code
        [Parameter(Mandatory = $false)]
        [int32] $ProcessExit = 0
  )

  begin {
      # Clear-Host
      $script:Date = Get-Date -Format "dddd MM/dd/yyyy HH:mm K"
      Write-Host "--------------------------------------" -ForegroundColor Green
      Write-Host " Start Installation  $script:Date" -ForegroundColor Green
  }
  process {
    ################################################################################
    # Set default installPath if not provide
    ################################################################################
    if (-not $installPath) {
      $installPath = "$env:LOCALAPPDATA"
    }
    Write-Verbose "installPath = $installPath"

    ################################################################################
    # Get Version
    ################################################################################
    if (-not $version) {
      $version = Get-LatestVersion
    }
    Write-Host "Sensing-Dev $version will be installed." 

    $baseUrl = "https://github.com/$repositoryName/releases/download/"

    ################################################################################
    # Get Working Directory
    ################################################################################
    $tempWorkDir = Join-Path -Path $env:TEMP -ChildPath $installerName
    if (-not (Test-Path $tempWorkDir)) {
        New-Item -ItemType Directory -Path $tempWorkDir | Out-Null
    }
    Write-Verbose "Working Directory = $tempWorkDir"

    $tempExtractionPath = "$tempWorkDir\_tempExtraction"
    if (Test-Path $tempExtractionPath) {
      Remove-Item -Path $tempExtractionPath -Force -Recurse
    }
    New-Item -ItemType Directory -Path $tempExtractionPath | Out-Null
    
    ################################################################################
    # Get Config & Check content
    ################################################################################
    $configFileName = "config_Windows.json"
    $configURL = "${baseUrl}${version}/$configFileName"
    $configPath = "$tempWorkDir/$configFileName"
    Invoke-WebRequest -Uri $configURL -OutFile $configPath -Verbose

    if (Test-Path $configPath) {
      try {
        $content = Get-Content -Path $configPath -Raw | ConvertFrom-Json
        Write-Verbose "The config file $configFileName has been downloaded and is a valid JSON."
      } catch {
        throw  "The confg file $configFileName is not a valid JSON."
      }
    } else {
      throw  "The config file $configFileName was not downloaded."
    }

    ################################################################################
    # Dlownload Aravis to $tempWorkDir & extract to $tempExtractionPath
    ################################################################################ 
    Write-Host "Aravis $content.aravis.version will be installed"
    Invoke-WebRequest -Uri $content.aravis.pkg_url -OutFile "$tempWorkDir/aravis.zip" -Verbose

    CheckComponentHash -compName "Aravis" -archivePath "$tempWorkDir/aravis.zip" -expectedHash $content.aravis.pkg_sha
    Expand-Archive -Path "$tempWorkDir/aravis.zip" -DestinationPath $tempExtractionPath 

    

  #   
  #   $installerPostfixName = if ($InstallOpenCV) { "" } else { "-no-opencv" }
  #   $script:Url = $Url
  #   # Construct download URL if not provided
  #   if (-not $Url -and -not $LocalInstaller) {
  #     $baseUrl = "https://github.com/Sensing-Dev/sensing-dev-installer/releases/download/"
    
  #     if (-not $version) {
  #       $version = Get-LatestVersion
  #     }
    
  #     if ($version -match 'v(\d+\.\d+\.\d+)(-\w+)?') {
  #       $versionNum = $matches[1] 
  #       Write-Output "Installing version: $version" 
  #     }
  #     if ($versionNum -lt "24.01.01") {
  #       Write-Output "InstallOpenCV option is unsupported for this version. Please update the installer.ps1"
  #       $installerPostfixName = ""
  #     }
  #     $downloadBase = "${baseUrl}${version}/${installerName}${installerPostfixName}-${versionNum}-win64"
  #     $script:Url = if ($user) { "${downloadBase}.zip" } else { "${downloadBase}.msi" }
  #     Write-Host "URL : $Url"
  #   }

  #   # Check if the URL ends with .zip or .msi and call the respective function
  #   if ($Url.EndsWith("zip") -or $LocalInstaller.EndsWith("zip")) {      
  #     Install-ZIP -installPath $installPath  -installerName $installerName -installerPostfixName $installerPostfixName -versionNum $versionNum  
      
  #     if ($versionNum -lt "24.01.05"){
  #       Write-Output "version_info.json is not supported in this version. Please update the installer.ps1"
  #     }
  #     $jsonURL = "${baseUrl}${version}/version_info.json"
  #     Write-Host $installPath
  #     Invoke-WebRequest -Uri $jsonURL -OutFile "$installPath/$installerName/version_info.json" -Verbose

  #   }
  #   elseif ($Url.EndsWith("msi") -or $LocalInstaller.EndsWith("msi") ) {
  #     Install-MSI -installPath $installPath -installerName $installerName 
  #   }
  #   else {
  #     Write-Error "Unsupported installer format."
  #     $ProcessExit = 1
  #   }
  #   Set-InstallerEnvironment -installPath $installPath -installerName $installerName
  # }
  # end{
  #   if ($ProcessExit -eq 0) {
  #     Write-Host " Installation Success at $script:Date" -ForegroundColor Green
  #     Write-Host "--------------------------------------" -ForegroundColor Green
  #   }
  #   else {
  #       Write-Error " Installation Failed at $script:Date"
  #       Write-Host "--------------------------------------" -ForegroundColor Green
  #   }
  #   exit $ProcessExit
  }
}

#--------------------------------------------------------------

Invoke-Script


