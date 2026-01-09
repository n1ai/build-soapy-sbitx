set -ex

[ -r vars-import.sh ] && . vars-import.sh || false
pushd ${TOP}

banner "SoapyPluto"

# dependencies come from debian repo
sudo apt install -y \
  libiio-dev libad9361-dev libusb-1.0-0-dev

# Install SoapyPluto
pushd ${TOP}
[ ! -d  SoapyPlutoSDR ] && \
  git clone https://github.com/pothosware/SoapyPlutoSDR.git
cd SoapyPlutoSDR
git pull
rm -rf build
mkdir build && cd build
cmake ..
make ${JFLAG}
sudo make install
sudo ldconfig
SoapySDRUtil --info
popd

banner "SoapyInfo"
SoapySDRUtil --info
banner "SoapyFind"
SoapySDRUtil --find

popd  # TOP
