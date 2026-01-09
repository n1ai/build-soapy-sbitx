set -ex

[ -r vars-import.sh ] && . vars-import.sh || false
pushd ${TOP}

banner "RtlSdrBlog"
pushd ${TOP}
# sudo apt purge -y ^librtlsdr
# sudo apt autoremove --purge
sudo rm -rvf /usr/lib/librtlsdr* /usr/include/rtl-sdr* /usr/local/lib/librtlsdr* /usr/local/include/rtl-sdr* /usr/local/include/rtl_* /usr/local/bin/rtl_*
[ ! -d rtl-sdr-blog ] && git clone https://github.com/rtlsdrblog/rtl-sdr-blog
cd rtl-sdr-blog
git pull
rm -rf build
mkdir build && cd build
cmake .. -DINSTALL_UDEV_RULES=ON |& tee cmake.log
make ${JFLAG}
sudo make install
sudo ldconfig
# blacklist the dvb usb driver
echo 'blacklist dvb_usb_rtl28xxu' | \
  sudo tee --append /etc/modprobe.d/blacklist-dvb_usb_rtl28xxu.conf
popd

banner "SoapRtlSdr"
pushd ${TOP}
[ ! -d SoapyRTLSDR ] && git clone https://github.com/pothosware/SoapyRTLSDR.git
cd SoapyRTLSDR
git pull 
rm -rf build
mkdir build && cd build
cmake ..
make ${JFLAG}
sudo make install
sudo ldconfig
banner "SoapyInfo"
SoapySDRUtil --info
banner "SoapyFind"
SoapySDRUtil --find
popd 
