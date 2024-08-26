param (
    [string]$cachePath
)

$defaultcachePath="C:\pygobject_cache"

# Validate if the provided cachePath parameter is empty
if (-not $cachePath) {
    Write-Output "Using default cache path: $defaultcachePath"
    $cachePath = $defaultcachePath
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
$pkgconfigDirectory = "$cachePath\pkg-config-lite-0.28-1\bin"

winget install --accept-source-agreements --accept-package-agreements --id $pkgConfigLiteAppId  --location $cachePath

$env:PATH += ";$pkgconfigDirectory"
Write-Output "Added $pkgconfigDirectory to PATH for the current session"

# Get latest vcpkg.exe
$vcpkgRoot = "C:\vcpkg"
$vcpkgExe = "$vcpkgRoot\vcpkg.exe"
# Check if vcpkg is already installed
if (-Not (Test-Path -Path "$vcpkgRoot\vcpkg.exe")) {
    Write-Output "Downloading and installing vcpkg..."
    # Clone the latest vcpkg repository
    git clone https://github.com/microsoft/vcpkg.git $vcpkgRoot
    # Bootstrap vcpkg
    & "$vcpkgRoot\bootstrap-vcpkg.bat"
}

# Install gobject-introspection using vcpkg
Write-Output "Installing gobject-introspection..."

& $vcpkgExe install gobject-introspection --x-install-root "$cachePath\vcpkg_installed"

# Get the path to the vcpkg installed pkgconfig directory
$vcpkgPkgConfigPath = "$cachePath\vcpkg_installed\x64-windows\lib\pkgconfig"

# Set the PKG_CONFIG_PATH environment variable for the current session
Write-Output "Setting PKG_CONFIG_PATH to $vcpkgPkgConfigPath for the current session"
$Env:PKG_CONFIG_PATH = $vcpkgPkgConfigPath

# Install pygobject from the Git repository with specific configuration settings
Write-Output "Installing pygobject from Git repository..."
pip install --config-settings=setup-args="-Dtests=false" git+https://gitlab.gnome.org/GNOME/pygobject.git


# Check if the vcpkg directory exists
if (Test-Path -Path $cachePath) {
    # Delete the vcpkg directory recursively
    Remove-Item -Path "$cachePath\vcpkg_installed" -Recurse -Force
    Write-Output "Please wait cache vcpkg_installed directory to be deleted: "$cachePath\vcpkg_installed" ..."
} else {
    Write-Output "cache vcpkg_installed directory not found at:"$cachePath\vcpkg_installed""
}

# Unset the PKG_CONFIG_PATH environment variable
Remove-Item Env:\PKG_CONFIG_PATH
Write-Output "Removed PKG_CONFIG_PATH environment variable"

Write-Output "$path Script completed."