<#
.SYNOPSIS
Uninstalls the Sensing SDK.

.DESCRIPTION
This script remove all content of sensing-dev in the default install path and remove all related environment variables.

.PARAMETER Verbose
Specifies the version of the Sensing SDK to be installed. Default is 'latest'.

.EXAMPLE
PS C:\> .\uninstaller.ps1 -Verbose

.NOTES
Ensure that you have the necessary permissions to install software and write to the specified directories.

.LINK
https://sensing-dev.github.io/doc/

#>

[cmdletbinding()]
param()

$target_directory_exist = $true
$sensing_dev_root_exist = $true

# Check if SENSING_DEV_ROOT exist
$sensing_dev_root = [Environment]::GetEnvironmentVariable("SENSING_DEV_ROOT", "User")
if (-not $sensing_dev_root) {
    Write-Verbose -Message "Environment variable SENSING_DEV_ROOT exist: NO (will check under AppData\Local)"
    $sensing_dev_root = "$env:LOCALAPPDATA\sensing-dev"
    $sensing_dev_root_exist = $false
}else{
    Write-Verbose -Message "Environment variable SENSING_DEV_ROOT exist: YES ($sensing_dev_root)" 
}

# Check if directory exist 
if (Test-Path $sensing_dev_root){
    Write-Verbose -Message "Directory $sensing_dev_root exist: YES" 
}else{
    Write-Verbose -Message "Directory $sensing_dev_root exist: NO --skip uninstall" 
    $target_directory_exist = $false
}

# Check if OpenCV exist only if v24.05 or later
## Check if version_info.json exist
if (Test-Path "$sensing_dev_root/version_info.json"){
    Write-Verbose -Message "Found version_info.json i.e. v24.05 or later"
    if (Test-Path "$sensing_dev_root/opencv"){
        Write-Verbose -Message "OpenCV is installed under SENSING_DEV_ROOT, which will be also uninstalled"
    }
}elseif ($target_directory_exist){
    Write-Verbose -Message "SDK is v24.01 or earlier"
}

# Delete the directory

if ($target_directory_exist){
    Write-Host "The following items will be deleted"
    Get-ChildItem -Path $sensing_dev_root
    Remove-Item -Recurse -Force -Path $sensing_dev_root
}

# Delete if PATH has 1. bin 2. OpenCV bin if OpenCV exists
$expected_sensing_dev_bin = "$sensing_dev_root\bin"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($currentPath.Contains($expected_sensing_dev_bin)) {
    Write-Verbose -Message "PATH contains Sensing-Dev dll path: YES"
    $newPath = $currentPath -replace [regex]::Escape($expected_sensing_dev_bin), ""
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Output "Removed '$expected_sensing_dev_bin' from User Path environment variable."
}else{
    Write-Verbose -Message "PATH contains Sensing-Dev dll path: NO --skip removal"
}

$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$expected_opencv_bin_pattern = [regex]::Escape("$sensing_dev_root\opencv\build\x64\vc") + "\d{1,2}\\bin"
$matches = $currentPath -split ";" | Where-Object { $_ -match $expected_opencv_bin_pattern }

if ($matches.Count -gt 0) {
    Write-Verbose -Message "PATH contains Sensing-Dev OpenCV dll path: YES"
    foreach ($match in $matches) {
        $expected_opencv_bin =  $match
        $newPath = $currentPath -replace [regex]::Escape($expected_opencv_bin), ""
        $currentPath = $newPath
        Write-Output "Removed '$expected_opencv_bin' from User Path environment variable."
    }
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
} else {
    Write-Verbose -Message "PATH contains Sensing-Dev OpenCV dll path: NO --skip removal"
}

# Delete if PYTHONPATH has sensing-dev related
$expected_pythonpath = "$sensing_dev_root\lib\site-packages"
$currentPythonPath = [Environment]::GetEnvironmentVariable("PYTHONPATH", "User")

if ($currentPythonPath -and $currentPythonPath.Contains($expected_pythonpath)) {
    Write-Verbose -Message "PYTHONPATH contains Sensing-Dev sitepackages path: YES"
    $newPath = $currentPythonPath -replace [regex]::Escape($expected_pythonpath), ""
    [Environment]::SetEnvironmentVariable("PYTHONPATH", $newPath, "User")
    Write-Output "Removed '$expected_pythonpath' from User PYTHONPATH environment variable."
}else{
    Write-Verbose -Message "PYTHONPATH contains Sensing-Dev sitepackages path: NO --skip removal"
}

# Delete if GST_PLUGIN_PATH has sensing-dev related
$currentGSTPATH = [Environment]::GetEnvironmentVariable("GST_PLUGIN_PATH", "User")
$expected_gst_plugin_pattern = [regex]::Escape("$sensing_dev_root")

$matches = $currentGSTPATH -split ";" | Where-Object { $_ -match $expected_gst_plugin_pattern }

if ($matches.Count -gt 0) {
    Write-Verbose -Message "GST_PLUGIN_PATH contains Sensing-Dev gst-plugin path: YES"
    foreach ($match in $matches) {
        $expected_gst_plugin =  $match
        $newPath = $currentGSTPATH -replace [regex]::Escape($expected_gst_plugin), ""
        $currentGSTPATH = $newPath
        Write-Output "Removed '$expected_gst_plugin' from User Path environment variable."
    }
    [Environment]::SetEnvironmentVariable("GST_PLUGIN_PATH", $newPath, "User")
} else {
    Write-Verbose -Message "GST_PLUGIN_PATH contains Sensing-Dev gst-plugin path: NO --skip removal"
}

# Delete if SENSING_DEV_ROOT
if ($sensing_dev_root_exist){
    [Environment]::SetEnvironmentVariable("SENSING_DEV_ROOT", "", "User")
    Write-Output "Removed '$sensing_dev_root' from User SENSING_DEV_ROOT environment variable."
}else{
    Write-Verbose -Message "SENSING_DEV_ROOT exists: NO --skip removal"
}