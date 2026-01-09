set -ex

[ -r vars-import.sh ] && . vars-import.sh || false
pushd ${TOP}

# build wdsp
# note: so far I haven't needed to fork it
[ ! -d wdsp-g0orx ] && git clone --depth 1 \
  https://github.com/g0orx/wdsp.git wdsp-g0orx
pushd wdsp-g0orx
git pull
make ${JFLAG} 
# make a copy of the library with a customized name
cp -p libwdsp.so libwdsp-g0orx.so
# install the copy 
sudo install -m 0755 libwdsp-g0orx.so /usr/local/lib
popd

# build the app
[ ! -d pihpsdr-g0orx ] && \
  git clone --branch soapy_sbitx --depth 1 \
  https://github.com/n1ai/pihpsdr-g0orx
pushd pihpsdr-g0orx
git pull

# scavanging LINUX/libinstall.txt for the parts we need
TARGET="${TOP}/pihpsdr-g0orx/LINUX"
mkdir -p $TARGET
rm -f $HOME/Desktop/pihpsdr-g0orx.desktop
rm -f $HOME/.local/share/applications/pihpsdr-g0orx.desktop
cat <<EOT > $TARGET/pihpsdr.sh
cd $TARGET
$TARGET/../pihpsdr >log 2>&1
EOT
chmod +x $TARGET/pihpsdr.sh
cat <<EOT > $TARGET/pihpsdr-g0orx.desktop
#!/usr/bin/env xdg-open
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Name[en_US]=piHPSDR-G0ORX
Path=$TARGET
Exec=$TARGET/pihpsdr.sh
Icon=$TARGET/hpsdr_icon.png
Name=piHPSDR-G0ORX
EOT
cp $TARGET/pihpsdr-g0orx.desktop $HOME/Desktop
mkdir -p $HOME/.local/share/applications
cp $TARGET/pihpsdr-g0orx.desktop $HOME/.local/share/applications
# cp $TARGET/release/pihpsdr/hpsdr.png $TARGET
# cp $TARGET/release/pihpsdr/hpsdr_icon.png $TARGET
cp release/pihpsdr/hpsdr.png $TARGET
cp release/pihpsdr/hpsdr_icon.png $TARGET

# build it!
make ${JFLAG} clean
make ${JFLAG} 

popd  # pihpsdr-g0orx
popd  # $TOP

