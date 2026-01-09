set -ex

[ -r vars-import.sh ] && . vars-import.sh || false
pushd ${TOP}

# Install AirSpyHF+ API
banner "AirSpyHF"
echo "Installing AirSpyHF+ API..."
pushd ${TOP}
[ ! -d  airspyhf ] && \
  git clone https://github.com/airspy/airspyhf.git
cd airspyhf
git pull
rm -rf build 
mkdir build && cd build
cmake .. -Wno-dev -DINSTALL_UDEV_RULES=ON -DUSE_UACCESS_RULES=ON |& tee cmake.log
make -j4 |& tee make.log
sudo make install
sudo ldconfig
popd

# Install SoapyAirspyHF
banner "SoapyAirSp"
echo "Installing SoapyAirspyHF..."
pushd ${TOP}
[ ! -d  SoapyAirspyHF ] && \
  git clone https://github.com/pothosware/SoapyAirspyHF.git
cd SoapyAirspyHF
git pull
rm -rf build
mkdir build && cd build
cmake .. 
make ${JFLAG}
sudo make install
sudo ldconfig
SoapySDRUtil --info
popd


# NOTE: Had to manually fix /etc/udev/rules.d/52-airspyhf.rules so it worked
# not just from desktop but also from user webrx group plugdev
# Original:
# ATTR{idVendor}=="03eb", ATTR{idProduct}=="800c", SYMLINK+="airspyhf-%k", TAG+="uaccess"
# New: remove TAG, and MODE and GROUP since this works for rtl-sdr
# ATTR{idVendor}=="03eb", ATTR{idProduct}=="800c", SYMLINK+="airspyhf-%k", MODE="660", GROUP="plugdev"

banner "SoapyInfo"
SoapySDRUtil --info
banner "SoapyFind"
SoapySDRUtil --find

popd  # TOP
