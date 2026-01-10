set -ex

[ -r vars-import.sh ] && . vars-import.sh || false
pushd ${TOP}

# Install SDRplay API only if necessary
n=`ldconfig -p | grep sdrplay | wc -l`
if [ $n -eq 0 ] 
then
  banner "SdrPlayAPI"
  SPAPI="SDRplay_RSP_API-Linux-3.15.2.run"
  echo "Installing SDRplay API..."
  mkdir -p ${TOP}/SDRplay-API
  pushd ${TOP}/SDRplay-API
  if [ ! -f "${SPAPI}" ] 
  then 
    wget -nc https://www.sdrplay.com/software/${SPAPI}
    echo "Running SDRplay installer (press Enter, then q, then y, then y when prompted)"
   sudo bash ${SPAPI}
  fi
  popd
fi

# Install SoapySDRPlay
banner "SoapySPlay"
pushd ${TOP}
[ ! -d  SoapySDRPlay ] && \
  git clone https://github.com/pothosware/SoapySDRPlay.git
cd SoapySDRPlay
git pull 
rm -rf build
mkdir -p build && cd build
cmake ..
make ${JFLAG}
sudo make install
sudo ldconfig
banner "SoapyInfo"
SoapySDRUtil --info
banner "SoapyFind"
SoapySDRUtil --find

popd  # TOP
