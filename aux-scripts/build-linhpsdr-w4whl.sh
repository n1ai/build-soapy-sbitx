set -ex

[ -r vars-import.sh ] && . vars-import.sh || false
pushd ${TOP}

sudo apt-get install -y libsoundio-dev

[ ! -d linhpsdr-w4whl ] && git clone --depth 1 \
  https://github.com/willardharris/linhpsdr.git linhpsdr-w4whl
pushd linhpsdr-w4whl
git pull

# Patch the Makefile to use the local wdsp
if git diff --quiet Makefile; then
    # generate the patch for the code
    patch -p1 << 'EOF'
diff --git a/Makefile.linux b/Makefile.linux
index 76fd239..6892f8b 100644
--- a/Makefile.linux
+++ b/Makefile.linux
@@ -70,13 +70,13 @@ MIDI_OBJS= alsa_midi.o midi2.o midi3.o midi_dialog.o
 MIDI_LIBS= -lasound
 endif
 
-CFLAGS=	-g -O2 -Wall -Wno-deprecated-declarations -O3
+CFLAGS=	-g -O2 -Wall -Wno-deprecated-declarations -O3 -I$(PWD)/wdsp
 OPTIONS=  $(MIDI_OPTIONS) $(AUDIO_OPTIONS)  $(SOAPYSDR_OPTIONS) \
          $(CWDAEMON_OPTIONS)  $(OPENGL_OPTIONS) \
          -D GIT_DATE='"$(GIT_DATE)"' -D GIT_VERSION='"$(GIT_VERSION)"'
 #OPTIONS=-g -Wno-deprecated-declarations $(AUDIO_OPTIONS) -D GIT_DATE='"$(GIT_DATE)"' -D GIT_VERSION='"$(GIT_VERSION)"' -O3 -D FT8_MARKER
 
-LIBS=-lrt -lm -lpthread -lwdsp $(GTKLIBS) $(AUDIO_LIBS) $(SOAPYSDR_LIBS) $(CWDAEMON_LIBS) $(OPENGL_LIBS) $(MIDI_LIBS)
+LIBS=-lrt -lm -lpthread $(PWD)/wdsp/libwdsp.a -lfftw3 $(GTKLIBS) $(AUDIO_LIBS) $(SOAPYSDR_LIBS) $(CWDAEMON_LIBS) $(OPENGL_LIBS) $(MIDI_LIBS)
 
 INCLUDES=$(GTKINCLUDES) $(OPGL_INCLUDES)
 
@@ -278,4 +278,4 @@ debian:
 	cp hpsdr_icon.png pkg/linhpsdr/usr/share/linhpsdr
 	cp hpsdr_small.png pkg/linhpsdr/usr/share/linhpsdr
 	cp linhpsdr.desktop pkg/linhpsdr/usr/share/applications
-	cd pkg; dpkg-deb --build linhpsdr
\ No newline at end of file
+	cd pkg; dpkg-deb --build linhpsdr
EOF
fi

# Patch the soapy discovery code to set the sample rate for sbitx
if git diff --quiet src/soapy_discovery.c; then
    # Traditional sample rate fix for linhpsdr
    patch -p1 << 'EOF'
diff --git a/soapy_discovery.c b/soapy_discovery.c
index cd816c1..9f6cd06 100644
--- a/soapy_discovery.c
+++ b/soapy_discovery.c
@@ -114,6 +114,8 @@ static void get_info(char *driver) {
   sample_rate=768000;
   if(strcmp(driver,"rtlsdr")==0) {
     sample_rate=1536000;
+  } else if(strcmp(driver,"sbitx")==0) {
+    sample_rate=48000;
   }
   fprintf(stderr,"sample_rate selected %d\n",sample_rate);
EOF
fi

# WDSP code
pushd wdsp
# build it!
make ${JFLAG} clean
make ${JFLAG}
# do NOT install it!
popd

# Application code
# build it!
make ${JFLAG} clean
make ${JFLAG}
# do NOT install it!

popd  # linhpsdr-w4whl
popd  # TOP
