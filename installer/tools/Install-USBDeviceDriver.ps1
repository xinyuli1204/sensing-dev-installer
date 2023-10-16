
<#
.SYNOPSIS
    Install USB device driver using WinUSB and run a driver installer.

.DESCRIPTION
    This PowerShell script installs a USB device driver using WinUSB and then runs a driver installer. It also deletes temporary files after the installation.

.PARAMETER installPath
    The path to the installation directory where required files are located.

.NOTES
    File Name      : Install-USBDeviceDriver.ps1
    Prerequisite   : PowerShell 5.0 or later

.EXAMPLE
    .\Install-USBDeviceDriver.ps1 -installPath "C:\Path\To\Installation"

    This example runs the script to install a USB device driver located in the specified installation path.

#>
param(
    [string]$installPath= (Split-Path $PSScriptRoot -Parent)    
)
# Download win_usb installer

$repoUrl = "https://api.github.com/repos/Sensing-Dev/${installerName}/releases/latest"
$response = Invoke-RestMethod -Uri $repoUrl
$version = $response.tag_name
Write-Verbose "Latest version: $version" 

if ($version -match 'v(\d+\.\d+\.\d+)(-\w+)?') {
    $versionNum = $matches[1] 
    Write-Output "Installing version: $version" 
}
$installerName = "winusb"

$zipUrl = "https://github.com/Sensing-Dev/sensing-dev-installer/releases/download/v${versionNum}/${installerName}.zip"

if ($Url.EndsWith("zip")) {
    # Download ZIP to a temp location

    $tempZipPath = "${env:TEMP}\${installerName}.zip"
    Invoke-WebRequest -Uri $Url -OutFile $tempZipPath -Verbose

    Add-Type -AssemblyName System.IO.Compression.FileSystem

    $tempExtractionPath = "$installPath\_tempExtraction"
    # Create the temporary extraction directory if it doesn't exist
    if (-not (Test-Path $tempExtractionPath)) {
        New-Item -Path $tempExtractionPath -ItemType Directory
    }
    # Attempt to extract to the temporary extraction directory
    try {
        [System.IO.Compression.ZipFile]::ExtractToDirectory($tempZipPath, $tempExtractionPath)
                
        # Cleanup the temporary extraction directory
        Remove-Item -Path $tempExtractionPath -Force -Recurse
    }
    catch {
        Write-Error "Extraction failed. Original contents remain unchanged."
        # Optional: Cleanup the temporary extraction directory
        Remove-Item -Path $tempExtractionPath -Force -Recurse
    }    
     # Optionally delete the ZIP file after extraction
     Remove-Item -Path $tempZipPath -Force
}


# Run Winusb installer

Write-Verbose "Start winUsb installer"
$TempDir = "$tempExtractionPath/winusb_installer/temp"
	
New-item -Path "$TempDir" -ItemType Directory
$winUSBOptions = @{
    FilePath               = "${tempExtractionPath}/winusb_installer/winusb_installer.exe"
    ArgumentList           = "054c"
    WorkingDirectory       = "$TempDir"
    Wait                   = $true
    Verb                   = "RunAs"  # This attempts to run the process as an administrator
}
Start-Process @winUSBOptions
Write-Verbose "End winUsb installer"

# Run Driver installer

Write-Verbose "Start Driver installer"

$infPath = "$TempDir/target.inf"
if (-not (Test-Path -Path $infPath -PathType Leaf) ){
    Write-Error "$infPath does not exist."
}
else{
    $pnputilOptions = @{
        FilePath = "PUNPUTIL"
        ArgumentList           = "-i -a $infPath"
        WorkingDirectory       = "$TempDir"
        Wait                   = $true
        Verb                   = "RunAs"  # This attempts to run the process as an administrator
    }
    Start-Process @pnputilOptions
}

# delete temp files

Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"Remove-Item -Path '$TempDir' -Recurse -Force -Confirm:`$false`""

Write-Verbose "End Driver installer"