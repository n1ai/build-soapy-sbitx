set -ex

[ -r vars-import.sh ] && . vars-import.sh || false
pushd ${TOP}

[ ! -d pihpsdr-dl1ycf ] && git clone --depth 1 \
  https://github.com/dl1ycf/pihpsdr pihpsdr-dl1ycf
pushd pihpsdr-dl1ycf
git stash  # Save old files so we can modify any newly-pulled version
git pull

# generate the patch for the Makefile
cat > Makefile.diff <<EOF
--- a/Makefile
+++ b/Makefile
@@ -12,11 +12,11 @@
 #
 #######################################################################################
 
-GPIO=ON
+GPIO=OFF
 MIDI=ON
-SATURN=ON
+SATURN=OFF
 USBOZY=OFF
-SOAPYSDR=OFF
+SOAPYSDR=ON
 STEMLAB=OFF
 AUDIO=PULSE
 NR34LIB=OFF
EOF
# apply the patch for the code
patch -p1 < Makefile.diff

# scavanging LINUX/libinstall.txt for the parts we need
export TARGET="${TOP}/pihpsdr-dl1ycf/LINUX"
rm -f $HOME/Desktop/pihpsdr-dl1ycf.desktop
rm -f $HOME/.local/share/applications/pihpsdr-dl1ycf.desktop
cat <<EOT > $TARGET/pihpsdr.sh
cd $TARGET
$TARGET/../pihpsdr >log 2>&1
EOT
chmod +x $TARGET/pihpsdr.sh
cat <<EOT > $TARGET/pihpsdr-dl1ycf.desktop
#!/usr/bin/env xdg-open
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Name[en_US]=piHPSDR-DL1YCF
Path=$TARGET
Exec=$TARGET/pihpsdr.sh
Icon=$TARGET/hpsdr_icon.png
Name=piHPSDR-DL1YCF
EOT
cp $TARGET/pihpsdr-dl1ycf.desktop $HOME/Desktop
mkdir -p $HOME/.local/share/applications
cp $TARGET/pihpsdr-dl1ycf.desktop $HOME/.local/share/applications
# cp $TARGET/release/pihpsdr/hpsdr.png $TARGET
# cp $TARGET/release/pihpsdr/hpsdr_icon.png $TARGET
cp release/pihpsdr/hpsdr.png $TARGET
cp release/pihpsdr/hpsdr_icon.png $TARGET

# generate the patch for the code
cat > patch-sample-rate.diff <<EOF
--- a/src/soapy_discovery.c
+++ b/src/soapy_discovery.c
@@ -146,6 +146,8 @@ static void get_info(char *driver) {
 
   if (strcmp(driver, "rtlsdr") == 0) {
     sample_rate = 1536000;
+  } else if (strcmp(driver, "sbitx") == 0) {
+    sample_rate = 48000;
   } else if (strcmp(driver, "radioberry") == 0) {
     sample_rate = 48000;
   }
EOF
# apply the patch for the code
patch -p1 < patch-sample-rate.diff

# build it!
make ${JFLAG} clean
make ${JFLAG}
# do NOT install it!

popd  # pihpsdr-dl1ycf
popd  # $TOP

