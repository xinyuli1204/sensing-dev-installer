#!/bin/bash
: '
.SYNOPSIS
Installs the Sensing SDK.

.DESCRIPTION
This script downloads and installs the Sensing SDK on Ubuntu. You can specify a particular version or the latest version will be installed by default.

.PARAMETER version/-v
Specifies the version of the Sensing SDK to be installed. Default is 'latest'.

.PARAMETER install-opencv
If set, the script will also install OpenCV. This is not done by default.

.PARAMETER install-path
The installation path for the Sensing SDK.Default is the /opt/sensing-dev directory'

set -eo pipefail
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

unset ion_kit_config
declare -A ion_kit_config=( # Declare an associative array with default values
    ["v24.04.00"]="v1.8.0"
)

INSTALL_PATH=/opt/sensing-dev

while true; do
  case "$1" in
    --install-opencv )
      InstallOpenCV=true;
      shift ;;
    -v | --version )
      Version="$2";
      if [[ -z "${ion_kit_config[$Version]+_}" ]]; then
        echo "Error: Version '$Version' is not found from following versions for Linux"
        for v in "${!ion_kit_config[@]}"; do
          echo $v
        done
        exit 1
      fi
      shift; shift ;;
    --install-path )
      INSTALL_PATH="$2";
      shift; shift ;;
    -- )
      shift; break ;;
    * )
      break ;;
  esac
done

get_sensing-dev_latest_release() {

  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

if [ -z "$Version" ]; then
  Repository="Sensing-Dev/sensing-dev-installer"
  Version=`get_sensing-dev_latest_release $Repository`
  if [[ "$Version" == "v24.01.04" ]]; then
    Version="v24.04.00"
  fi
fi
ION_KIT_VERSION=${ion_kit_config["$Version"]}

mkdir -p $INSTALL_PATH

echo "**********"
echo "Install Dependencies"
echo "**********"
apt-get -y upgrade && apt-get install -y curl gzip git python3-pip glib2.0 libxml2-dev \
    libgirepository1.0-dev libnotify-dev \
    libunwind-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libgtk-3-dev \
    gtk-doc-tools


echo
echo "**********"
echo "Install aravis=0.8.30"
echo "**********"

curl -L https://github.com/Sensing-Dev/aravis/releases/download/internal-0.8.30/aravis-internal-0.8.30-x86-64-linux.tar.gz| tar zx -C $INSTALL_PATH --strip-components 1
mkdir -p /etc/udev/rules.d
cat > /etc/udev/rules.d/80-aravis.rules << EOS
SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", MODE:="0666", TAG+="uaccess", TAG+="udev-acl"
EOS
echo "INFO: Aravis installed"

# Install OpenCV if the flag is set to true
if [ "$InstallOpenCV" = true ]; then
    echo
    echo "**********"
    echo "Install OpenCV"
    echo "**********"
    TMPDIR=$(mktemp -d)
    curl -L https://ion-kit.s3.us-west-2.amazonaws.com/dependencies/OpenCV-4.5.2-x86_64-gcc75.sh -o ${TMPDIR}/OpenCV.sh
    sh ${TMPDIR}/OpenCV.sh --skip-license --prefix=$INSTALL_PATH
    echo "INFO: OpenCV installed"
fi


echo
echo "**********"
echo "Install ion-kit=${ION_KIT_VERSION/v/''}"
echo "**********"
if [ ${ION_KIT_VERSION} = v0.3.6 ]; then
   curl -L https://github.com/fixstars/ion-kit/releases/download/${ION_KIT_VERSION}/ion-kit-${ION_KIT_VERSION/v/''}-Linux.tar.gz | tar xz -C  $INSTALL_PATH --strip-components 1
else
  curl -L https://github.com/fixstars/ion-kit/releases/download/${ION_KIT_VERSION}/ion-kit-${ION_KIT_VERSION/v/''}-x86-64-linux.tar.gz | tar xz -C  $INSTALL_PATH --strip-components 1
fi


GENDC_SEPARATOR_VERSION="v0.2.0"

echo
echo "**********"
echo "Install GenDCSeparator=${GENDC_SEPARATOR_VERSION/v/''}"
echo "**********"
curl -L https://github.com/Sensing-Dev/GenDC/releases/download/${GENDC_SEPARATOR_VERSION}/gendc_separator_${GENDC_SEPARATOR_VERSION}_win64.zip -o gendc_separator.zip && unzip -o gendc_separator.zip -d $INSTALL_PATH/include && rm gendc_separator.zip

echo
echo "Successfully Finished."