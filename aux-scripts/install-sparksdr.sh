set -ex
# get the debian file for arm64
pushd $HOME/Downloads
wget https://www.sparksdr.com/download/SparkSDR.2.0.992.linux-arm64.deb
# see what is in it
dpkg-deb -c SparkSDR.2.0.992.linux-arm64.deb 
# install it
sudo dpkg -i SparkSDR.2.0.992.linux-arm64.deb 
# make a desktop icon
sudo cp /usr/share/applications/SparkSDR.desktop ~/Desktop
# redo the desktop icons
popd
