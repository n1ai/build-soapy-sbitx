#
# Note: This script is used when we build all of Soapy from scratch.
# Currently we use the Debian version of the main Soapy libs, headers and tools
# and just build various modules we want that are not in the Debian repo.
# We use individual scripts for those modules

# Set TOP if it isn't already set in the environment
: "${TOP:=${HOME}}"
# Set JFLAG if it isn't already set in the environment
: "${JFLAG:=-j$(nproc)}"

set -ex

# TODO: install libiio-dev for Pluto

echo \#########################################################################
echo airspyhf build
echo \#########################################################################

pushd ${TOP}
[ ! -d airspyhf ] && git clone https://github.com/airspy/airspyhf.git
cd airspyhf
git pull
rm -rf build
mkdir build && cd build
cmake .. -DINSTALL_UDEV_RULES=ON -DUSE_UACCESS_RULES=ON |& tee cmake.log
make ${JFLAG} |& tee make.log
sudo make install
sudo ldconfig
popd

# NOTE: Had to manually fix /etc/udev/rules.d/52-airspyhf.rules so it worked
# not just from desktop but also from user webrx group plugdev
# Original:
# ATTR{idVendor}=="03eb", ATTR{idProduct}=="800c", SYMLINK+="airspyhf-%k", TAG+="uaccess"
# New: remove TAG, and MODE and GROUP since this works for rtl-sdr
# ATTR{idVendor}=="03eb", ATTR{idProduct}=="800c", SYMLINK+="airspyhf-%k", MODE="660", GROUP="plugdev"

echo \#########################################################################
echo "rtl-sdr-blog build (not osmocom!)"
echo \#########################################################################

pushd ${TOP}
# sudo apt purge -y ^librtlsdr
# sudo apt autoremove --purge
sudo rm -rvf /usr/lib/librtlsdr* /usr/include/rtl-sdr* /usr/local/lib/librtlsdr* /usr/local/include/rtl-sdr* /usr/local/include/rtl_* /usr/local/bin/rtl_*
[ ! -d rtl-sdr-blog ] && git clone https://github.com/rtlsdrblog/rtl-sdr-blog
cd rtl-sdr-blog
git pull
sudo rm -rf build
mkdir build && cd build
cmake .. -DINSTALL_UDEV_RULES=ON |& tee cmake.log
make ${JFLAG} |& tee make.log
sudo make install
sudo ldconfig
# blacklist the dvb usb driver
echo 'blacklist dvb_usb_rtl28xxu' | \
  sudo tee --append /etc/modprobe.d/blacklist-dvb_usb_rtl28xxu.conf
popd

echo \#########################################################################
echo hackrf build
echo \#########################################################################

pushd ${TOP}
[ ! -d hackrf ] && git clone https://github.com/mossmann/hackrf.git
cd hackrf
git pull
cd host
rm -rf build
mkdir -p build && cd build
# note the cmake stuff is in "host" so you must build under that...
cmake ../ -DINSTALL_UDEV_RULES=ON |& tee cmake.log
make ${JFLAG} |& tee make.log
sudo make install
sudo ldconfig
popd

echo \#########################################################################
echo "SoapySDR (top-level) build"
echo \#########################################################################

pushd ${TOP}
[ ! -d SoapySDR ] && git clone https://github.com/pothosware/SoapySDR.git
cd SoapySDR
git pull
rm -rf build 
mkdir build && cd build
cmake .. \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DCMAKE_CXX_FLAGS="-frtti" \
  -DCMAKE_BUILD_TYPE=Release |& tee cmake.log
make ${JFLAG} |& tee make.log
sudo make install
sudo ldconfig
popd

echo \#########################################################################
echo SoapyHackRF build
echo \#########################################################################

pushd ${TOP}
[ ! -d SoapyHackRF ] && git clone https://github.com/pothosware/SoapyHackRF.git
cd SoapyHackRF
git pull
rm -rf build
mkdir build && cd build
cmake .. |& tee cmake.log
make ${JFLAG} |& tee make.log
sudo make install
sudo ldconfig
SoapySDRUtil --info
popd

echo \#########################################################################
echo SoapyRTLSDR build
echo \#########################################################################

pushd ${TOP}
[ ! -d SoapyRTLSDR ] && git clone https://github.com/pothosware/SoapyRTLSDR.git
cd SoapyRTLSDR
git pull 
rm -rf build
mkdir build && cd build
cmake .. |& tee cmake.log
make ${JFLAG} |& tee make.log
sudo make install
sudo ldconfig
SoapySDRUtil --info
popd

echo \#########################################################################
echo SoapyAirspyHF build
echo \#########################################################################

pushd ${TOP}
[ ! -d SoapyAirspyHF ] && git clone https://github.com/pothosware/SoapyAirspyHF
cd SoapyAirspyHF
git pull
rm -rf build
mkdir build && cd build
cmake .. |& tee cmake.log
make ${JFLAG} |& tee make.log
sudo make install
sudo ldconfig
SoapySDRUtil --info
popd

echo \#########################################################################
echo SoapyPlutoSDR build
echo \#########################################################################

pushd ${TOP}
[ ! -d SoapyPlutoSDR ] && git clone https://github.com/pothosware/SoapyPlutoSDR
cd SoapyPlutoSDR
git pull
rm -rf build
mkdir build && cd build
cmake .. |& tee cmake.log
make $(JFLAG) |& tee make.log
sudo make install
sudo ldconfig
SoapySDRUtil --info
popd

echo \#########################################################################
echo SoapyRemote build
echo \#########################################################################

pushd ${TOP}
[ ! -d SoapyRemote ] && git clone https://github.com/pothosware/SoapyRemote.git
cd SoapyRemote
git pull
rm -rf build
mkdir build && cd build
cmake .. |& tee cmake.log
make ${JFLAG} |& tee make.log
sudo make install
sudo ldconfig
SoapySDRUtil --info

