<#
.SYNOPSIS
Installs the Sensing SDK.

.DESCRIPTION
This script downloads and installs the Sensing SDK. You can specify a particular version or the latest version will be installed by default. It supports both .zip and .msi installers.

.PARAMETER version
Specifies the version of the Sensing SDK to be installed. Default is 'latest'.

.PARAMETER user
Specifies the username for which the Sensing SDK will be installed. This determines the installation path in the user's LOCALAPPDATA.

.PARAMETER Url
URL of the Sensing SDK installer. If not provided, the script constructs the URL based on the specified or default version.

.PARAMETER installPath
The installation path for the Sensing SDK. Default is the sensing-dev-installer directory in the user's LOCALAPPDATA.

.PARAMETER InstallOpenCV
If set, the script will also install OpenCV. This is not done by default.

.EXAMPLE
PS C:\> .\installer.ps1 -version 'v24.09.03' -user 'Admin' -Url 'http://example.com'

This example demonstrates how to run the script with custom version, user, and URL values.

.EXAMPLE
PS C:\> .\installer.ps1 -InstallOpenCV

This example demonstrates how to run the script with the default settings and includes the installation of OpenCV.

.NOTES
Ensure that you have the necessary permissions to install software and write to the specified directories.

.LINK
http://example.com/documentation-link

#>

param(
  [string]$version,
  [string]$user,
  [string]$Url,
  [string]$installPath,
  [switch]$InstallOpenCV = $false,
  [string]$LocalInstaller
)

function Set-InstallerEnvironment(){
    param (
      [string] $installPath,
      [string] $installerName,
      [switch] $InstallOpenCV = $false
    )
    $installPath
    if (Test-Path -Path ${installPath}) {
      $relativeScriptPath = "tools\Env.ps1"
      # Run the .ps1 file from the installed package
      $ps1ScriptPath = Join-Path -Path $installPath\$installerName -ChildPath $relativeScriptPath
      Write-Host "ps1ScriptPath = $ps1ScriptPath"
      if (Test-Path -Path $ps1ScriptPath -PathType Leaf) {
        $outputEnvScript = & $ps1ScriptPath -InstallOpenCV:$InstallOpenCV
        Write-Host $outputEnvScript
      }
      else {
        Write-Error "Script at $relativeScriptPath not found in the installation path!"
        exit 1
      }
    } 
  }

$installerName = "sensing-dev"

$UserProfilePath = "C:\Users\$user"
$installPath = Join-Path -Path $UserProfilePath -ChildPath "AppData\Local"

Write-Host "$InstallOpenCV"

Set-InstallerEnvironment -installPath $installPath -installerName $installerName -InstallOpenCV $InstallOpenCV