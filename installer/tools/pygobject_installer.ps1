param (
    [string]$CacheDIR
)

$defaultCacheDIR="C:\PyGObjectCache"

# Validate if the provided CacheDIR parameter is empty
if (-not $CacheDIR) {
    Write-Output "Using default cache path: $defaultCacheDIR"
    $CacheDIR = $defaultCacheDIR
}

# Define the application ID for pkg-config-lite
$pkgConfigLiteAppId = "bloodrock.pkg-config-lite"

# Check if pkg-config-lite is already installed using winget
$installedPackage = winget show --id $pkgConfigLiteAppId -e

if ($installedPackage) {
    Write-Output "Uninstalling existing $pkgConfigLiteAppId..."
    winget uninstall --id $pkgConfigLiteAppId
}

# Install pkg-config-lite using winget
Write-Output "Installing $pkgConfigLiteAppId..."

# Define the directory you want to remove from PATH
$pkgconfigDirectory = "$CacheDIR\pkg-config-lite-0.28-1\bin"
winget install --accept-source-agreements --accept-package-agreements --id $pkgConfigLiteAppId  --location $CacheDIR

$env:PATH += ";$pkgconfigDirectory"
Write-Output "Added $pkgconfigDirectory to PATH for the current session"

# Install gobject-introspection using vcpkg
Write-Output "Installing gobject-introspection..."


Invoke-WebRequest -Uri https://github.com/Sensing-Dev/aravis/releases/download/v0.8.31/PyGObject-1.72.0-dependencies.zip  -OutFile $CacheDIR\dependency.zip
Expand-Archive -Path $CacheDIR\dependency.zip -DestinationPath $CacheDIR\dependency
rm $CacheDIR\dependency.zip

$PkgConfigPath = "$CacheDIR\dependency\pygobject_dependencies\lib\pkgconfig"
# Set the PKG_CONFIG_PATH environment variable for the current session
Write-Output "Setting PKG_CONFIG_PATH to "$PkgConfigPath" for the current session"
$Env:PKG_CONFIG_PATH = $PkgConfigPath

# Install pygobject from the Git repository with specific configuration settings
Write-Output "Installing pygobject from Git repository..."
pip install --config-settings=setup-args="-Dtests=false" git+https://gitlab.gnome.org/GNOME/pygobject.git

# Delete the vcpkg directory recursively
Write-Output "Deleting cache directory: "$CacheDIR" ..."
Remove-Item -Path "$CacheDIR" -Recurse -Force

# Unset the PKG_CONFIG_PATH environment variable
Write-Output "Removing PKG_CONFIG_PATH environment variable"
Remove-Item Env:\PKG_CONFIG_PATH


Write-Output "Script completed."
