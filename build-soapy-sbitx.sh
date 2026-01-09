#!/bin/bash 
#
# Builds or installs the soapy-sbitx driver, the soapy-sdr infrastructure and 
# many soapy-capable sdr apps and utilities for use on the sbitx.
# x pihpsdr-g0orx
# x pihpsdr-dl1ycf
# x deskhpsdr-dl1bz
# x linhpsdr-w4whl
# x SparkSDR
# x CubicSDR
# x gqrx
# x quisk
#
# Note: I prefer to install using pre-build binaries if possible.  
# This reduces the resources consumed running this script.
# The exceptions are for SDR apps not in the repo or ones that have
# fixes that are important enough to build the app from source.
# Currently, quisk, gqrx and CubicSDR are installed from the debian
# repo and SparkSDR is installed via a debian package downloaded 
# from the author's website

# Start off with the warning
echo "Attention"
printf "This script will do a bunch of things you may or may not want:
  • It will update all the core Debian packages on the system \n\
  • it will make a new build directory at:\n\
      \t${TOP}\n\
  • It will build and/or install several new SDR libraries and apps\n\
    • These may or may not conflict with ones already on your system\n\
  • It will make your system run slowly for a long time while it runs\n\
  • It may crash or hang your system\n\
    • Especially if you have any major sdr apps or browsers running\n\
  • It may wait asking you to accept SdrPlay licenses\n\
"
read -rp "Do you want to continue? (y/n): " a && [[ "$a" == "y" ]] || exit 1
set -x

# Install the banner program so I can use it below
sudo apt-install -y sysvbanner

# Set the TOP variable to where you want most of this code to be built
# and export it to the environment (see also: vars-export.sh)
# I highly recommend you use the same location I used but have coded 
# the scripts to always reference TOP instead of assuming a location
banner "SetTopDir"
TOP=${HOME}/code/soapy-sbitx 
export TOP
mkdir -p ${TOP}
pushd ${TOP}
# set the "make" parallel compile flag based on the number of procs 
# you may have to hard-code this to less on slower Pis with less memory
JFLAG="-j$(nproc)"
export JFLAG

# get up to date
# this takes a long time if you haven't done it before
banner "OS-Updates"
sudo apt update && sudo apt -y upgrade

# install initial dependencies/tools
# this also takes a long time since gqrx has a lot of dependencies
# the 'true' part is needed since one dependency is broken
banner "Core-Deps"
sudo apt install -y \
  libsoapysdr-dev soapysdr-tools \
  soapysdr-module-remote soapyremote-server \
  airspy libairspy-dev soapysdr-module-airspy \
  gqrx-sdr libgnuradio-hpsdr1.0.0 quisk cubicsdr \
  pavucontrol || true

# remove xtrx-dkms since it's broken, then clean up
banner "FixInstall"
sudo apt remove -y xtrx-dkms || true
sudo apt autoremove -y || true

# fail on error from here on
set -ex

# install dependencies for the various *hpsdr apps
banner "Hpsdr-Deps"
sudo apt install -y \
    git build-essential cmake pkg-config \
    libfftw3-dev libgtk-3-dev libpulse-dev libpulse-mainloop-glib0 \
    libasound2-dev libusb-1.0-0-dev libi2c-dev libgpiod-dev 

# build WiringPi from the standard repo since sbitx_ctrl needs it
banner "WiringPi"
[ ! -d WiringPi ] && git clone https://github.com/WiringPi/WiringPi.git
pushd WiringPi
# WiringPi build script has install with sudo commands built-in
./build |& tee build.log
popd

# build sbitx_ctrl from my fork of the sbitx-core repo
banner "Sbitx-Ctrl"
[ ! -d sbitx-core ] && git clone https://github.com/n1ai/sbitx-core
pushd sbitx-core
git switch sbitx_ctrl
git pull
make clean
make sbitx_ctrl
sudo make install_sbitx_ctrl
popd

# build SoapySBITX from my fork of the sbitx-ham-apps repo
banner "SoapySBITX"
[ ! -d sbitx-ham-apps ] && git clone https://github.com/n1ai/sbitx-ham-apps
pushd sbitx-ham-apps
git switch level3_1227
git pull
pushd soapy2sbitx
rm -rf build
mkdir -p build && cd build
cmake .. |& tee cmake.log
make -j2
sudo make install
sudo ldconfig
banner "SoapyInfo"
SoapySDRUtil --info
banner "SoapyFind"
SoapySDRUtil --find
cd ..
popd  ## soapy2sbitx
popd  ## sbitx-ham-apps

# build soapy sdrplay using my script
pushd ${TOP}/build-soapy-sbitx
bash -x ./aux-scripts/build-soapy-sdrplay.sh
popd

# build soapy rtlsdr using my script
pushd ${TOP}/build-soapy-sbitx
bash -x ./aux-scripts/build-soapy-rtlsdr.sh
popd

# build soapy airspyhf+ using my script
pushd ${TOP}/build-soapy-sbitx
bash -x ./aux-scripts/build-soapy-sdrplay.sh
popd

# build soapy pluto using my script
pushd ${TOP}/build-soapy-sbitx
bash -x ./aux-scripts/build-soapy-pluto.sh
popd

# install sparksdr using my install script
pushd ${TOP}/build-soapy-sbitx
banner "SparkSDR++"
bash -x ./aux-scripts/install-sparksdr.sh
popd

# build pihpdr-g00rx using my build script
pushd ${TOP}/build-soapy-sbitx
banner "Hp-G0ORX"
bash -x ./aux-scripts/build-pihpsdr-g0orx.sh
popd

# build pihpdr-dl1ycf using my build script
pushd ${TOP}/build-soapy-sbitx
banner "Hp-DL1YCF"
bash -x ./aux-scripts/build-pihpsdr-dl1ycf.sh
popd

# build deskhpsdr using my build script
pushd ${TOP}/build-soapy-sbitx
banner "deskhpsdr"
bash -x ./aux-scripts/build-deskhpsdr.sh
popd

# build linhpsdr-w4whl using my build script
pushd ${TOP}/build-soapy-sbitx
banner "Lin-W4WHL"
bash -x ./aux-scripts/build-linhpsdr-w4whl.sh
popd

# build sdrpp using my build script
pushd ${TOP}/build-soapy-sbitx
banner "sdr++"
bash -x ./aux-scripts/build-sdrpp.sh
popd

popd # ${TOP}
banner "Done!"
