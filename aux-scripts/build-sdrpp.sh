set -ex

[ -r vars-import.sh ] && . vars-import.sh || false
pushd ${TOP}

sudo apt install -y libglfw3-dev libglew-dev libvolk2-dev \
  libzstd-dev libzstd1 portaudio19-dev libcodec2-dev librtaudio-dev

[ ! -d SDRPlusPlus ] && git clone \
  https://github.com/AlexandreRouma/SDRPlusPlus.git
pushd SDRPlusPlus
git pull
rm -rf build
mkdir build && cd build
cmake .. \
  -DOPT_BUILD_RTL_SDR_SOURCE=ON \
  -DOPT_BUILD_AIRSPY_SOURCE=ON \
  -DOPT_BUILD_AIRSPYHF_SOURCE=ON \
  -DOPT_BUILD_HACKRF_SOURCE=ON \
  -DOPT_BUILD_NEW_PORTAUDIO_SINK=ON \
  -DOPT_BUILD_SOAPY_SOURCE=ON \
  -DCMAKE_BUILD_TYPE=Release
make $(JFLAG)
sudo make install
sudo ldconfig

popd  # deskhpsdr
popd  # $TOP

