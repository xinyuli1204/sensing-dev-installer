param (
    [string]$CacheDIR
)

$pipExists = Get-Command pip -ErrorAction SilentlyContinue

if ($pipExists){
    Write-Host "pip exists"
} else {
    Write-Error "pip not found; please install it to run this script"
    exit 1
}

$defaultCacheDIR = Join-Path -Path "$env:TEMP" -ChildPath "PyGObjectCache" 

if (Test-Path $defaultCacheDIR) {
    Remove-Item -Path $defaultCacheDIR -Force -Recurse
}

# Validate if the provided CacheDIR parameter is empty
if (-not $CacheDIR) {
    Write-Output "Using default cache path: $defaultCacheDIR"
    $CacheDIR = $defaultCacheDIR
}

# Define the application ID for pkg-config-lite
$pkgConfigLiteAppId = "bloodrock.pkg-config-lite"

# Check if pkg-config-lite is already installed using winget
try {
    $installedPackage = winget show --id $pkgConfigLiteAppId -e --accept-source-agreements
    if ($installedPackage) {
        Write-Output "Uninstalling existing $pkgConfigLiteAppId..."
        winget uninstall --id $pkgConfigLiteAppId --accept-source-agreements
    }
} catch {
    Write-Error "Failed to check/uninstall existing pkg-config-lite: $_"
    exit 1
}

# Install pkg-config-lite using winget
Write-Output "Installing $pkgConfigLiteAppId..."
try {
    # Define the directory you want to remove from PATH
    $pkgconfigDirectory = "$CacheDIR\pkg-config-lite-0.28-1\bin"
    winget install --accept-source-agreements --accept-package-agreements --id $pkgConfigLiteAppId  --location $CacheDIR
} catch {
    Write-Error "Failed to install pkg-config-lite: $_"
    exit 1
}

$env:PATH += ";$pkgconfigDirectory"
Write-Output "Added $pkgconfigDirectory to PATH for the current session"

# Install gobject-introspection using vcpkg
Write-Output "Installing gobject-introspection..."

try {
    Invoke-WebRequest -Uri https://github.com/Sensing-Dev/aravis/releases/download/v0.8.31/PyGObject-1.72.0-dependencies.zip  -OutFile $CacheDIR\dependency.zip
    Expand-Archive -Path $CacheDIR\dependency.zip -DestinationPath $CacheDIR\dependency
    Remove-Item -Force $CacheDIR\dependency.zip
} catch {
    Write-Error "Failed to DL/extract gobject-introspection: $_"
    exit 1
}

$PkgConfigPath = "$CacheDIR\dependency\pygobject_dependencies\lib\pkgconfig"
# Set the PKG_CONFIG_PATH environment variable for the current session
Write-Output "Setting PKG_CONFIG_PATH to "$PkgConfigPath" for the current session"
$Env:PKG_CONFIG_PATH = $PkgConfigPath

# Install pygobject from the Git repository with specific configuration settings
Write-Output "Installing pygobject from Git repository..."
try {
    pip install --config-settings=setup-args="-Dtests=false" git+https://gitlab.gnome.org/GNOME/pygobject.git
} catch {
    Write-Error "Failed to install gobject-introspection: $_"
    exit 1
}

# Delete the vcpkg directory recursively
Write-Output "Deleting cache directory: "$CacheDIR" ..."
try {
    Remove-Item -Path "$CacheDIR" -Recurse -Force
} catch {
    Write-Error "Failed to remove vcpkg directory: $_"
    exit 1
}

# Unset the PKG_CONFIG_PATH environment variable
Write-Output "Removing PKG_CONFIG_PATH environment variable"
Remove-Item Env:\PKG_CONFIG_PATH


Write-Output "Script completed."
