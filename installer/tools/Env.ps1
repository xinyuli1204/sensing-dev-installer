<#
.SYNOPSIS
Script to update enviroment for sensing dev installer usage.

.DESCRIPTION
Script to update enviroment for sensing dev installer usage.

.PARAMETER installPath
Path of installation.

.EXAMPLE
.\Env.ps1
Runs the script with the default installPath set to the parent directory.

.EXAMPLE
.\YourScript.ps1 -InputPath "C:\example"
Runs the script with the installPath set to "C:\example".

.NOTES
File Name      : Env.ps1
Prerequisite   : PowerShell V3
#>
param(
    [string]$installPath= (Split-Path $PSScriptRoot -Parent)    
)

# Define the paths you want to add
$newPath = "${installPath}\bin"
$newPythonPath = "${installPath}\lib\site-packages"

Write-Output "installPath : $installPath"

# Get current PATH and PYTHONPATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$currentPythonPath = [Environment]::GetEnvironmentVariable("PYTHONPATH", "User")

# Update PATH if the new path is not already in it
if (-not $currentPath.Contains($newPath)) {
    $currentPath += ";$newPath"
    [Environment]::SetEnvironmentVariable("Path", $currentPath, "User")
}
Write-Verbose "Updated PATH: $currentPath"

# Update PYTHONPATH if the new path is not already in it
if (-not $currentPythonPath -or (-not $currentPythonPath.Contains($newPythonPath))) {
    if ($currentPythonPath) {
        $currentPythonPath += ";$newPythonPath"
    } else {
        $currentPythonPath = $newPythonPath
    }
    [Environment]::SetEnvironmentVariable("PYTHONPATH", $currentPythonPath, "User")
}
Write-Verbose "Updated PYTHONPATH: $currentPythonPath"


# Update SENSING_DEV_ROOT if the new path is not already in it
[Environment]::SetEnvironmentVariable("SENSING_DEV_ROOT", $installPath, "User")
Write-Verbose "Updated SENSING_DEV_ROOT: $installPath"

[Environment]::SetEnvironmentVariable("GST_PLUGIN_PATH", $installPath, "User")
Write-Verbose "Updated GST_PLUGIN_PATH: $installPath"


# Run Winusb installer

Write-Verbose "Start winUsb installer"
$TempDir = "$installPath/tools/winusb_installer/temp"
	
New-item -Path "$TempDir" -ItemType Directory
$winUSBOptions = @{
    FilePath               = "$installPath/tools/winusb_installer/winusb_installer.exe"
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

