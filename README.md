# ⚠️ **EXPERIMENTAL** ⚠️ 
# build-sbitx-soapy

Scripts to build and/or install Soapy components as well as some SoapySDR applications for use with the sBITX HF Transceiver:
- [SparkSDR](https://www.sparksdr.com/) ([manual](https://www.sparksdr.com/manual))
- [pihpsdr-g0orx](https://github.com/g0orx/pihpsdr) ([wiki](https://github.com/g0orx/pihpsdr/wiki))
- [pihpsdr-dl1ycf](https://github.com/dl1ycf/pihpsdr) ([manual](https://github.com/dl1ycf/pihpsdr/releases/download/v2.5/piHPSDR-Manual-v2.5.pdf))
- [deskhpsdr](https://github.com/dl1bz/deskhpsdr) ([discussions](https://github.com/dl1bz/deskhpsdr/discussions))
- [linhpsdr-w4whl](https://github.com/willardharris/linhpsdr) ([documentation](https://github.com/willardharris/linhpsdr/tree/master/documentation))
- [gqrx](https://github.com/gqrx-sdr/gqrx) ([homepage](https://www.gqrx.dk))
- [quisk](https://pypi.org/project/quisk) ([documentation](http://james.ahlstrom.name/quisk/docs.html))
- [CubicSDR](https://github.com/cjcliffe/CubicSDR) ([manual](https://cubicsdr.readthedocs.io/en/latest/))
- [SDRPlusPlus](https://github.com/AlexandreRouma/SDRPlusPlus) ([manual](https://www.sdrpp.org/manual.pdf))

Credits:
- Juan, WP3DN
- JJ, W9JES
- Rafael Diniz @ Rhizomatica
- Authors/Maintainers of the above SDR applications

## Prerequsites
- Boot [the 64-bit team's sbitx image](https://github.com/drexjj/sbitx/releases)
- It should be a freshly installed copy
- My scripts do not modify the sbitx app or its files
- My scripts will install new packages/programs that may supercede the ones on that image
- Therefore it's best to just start with fresh install if you can
- As per the link, make sure you use the 64-bit team's Backup Manager to save any important stuff off any copy of the image you are using and re-install the backup on the new copy

## Running The Script
- Open a Terminal window on the sbitx device
- Enter the following commands, which makes a new directory for all of the GitHub content to reside.  Note this page is formatted to make it easy to copy/paste the commands below.
```bash
cd $HOME
mkdir -p code/soapy-sbitx
cd code/soapy-sbitx
```
- Enter the following commands to download this repository from GitHub and to enter its main directory
```bash
git clone https://n1ai/build-soapy-sbitx.git
cd build-soapy-sbitx
```
- To run the script for first time, without capturing its output, just do:
```bash
bash ./build-soapy-sbitx.sh
```
- You will know when it is done when it outputs the following:
```
######                            ###
#     #   ####   #    #  ######   ###
#     #  #    #  ##   #  #        ###
#     #  #    #  # #  #  #####     #
#     #  #    #  #  # #  #
#     #  #    #  #   ##  #        ###
######    ####   #    #  ######   ###
```
- If it fails, run it a second time capturing its output using the `tee` command:
```bash
bash ./build-soapy-sbitx.sh |& tee build-soapy-sbitx.log
```
- Then you can share the log file on Discord or open a GitHub Issue and attach the log file to that Issue.
- As the script output says, the script will run a LONG time.  It may even fail or lock up the system or crash it.  Let me know if this happens.  
- When it finishes, use the Pi main menu's *Logout -> Shutdown* menu to shut down the sbitx, then cycle its power off then on, then let it boot again.  When the desktop re-opens you should see the icons for the new apps we just installed or built on the desktop.

## Running the sbitx_control program

To use the Soapy sBITX software, you will first need to start the sbtix_ctrl program.  This program controls the sbitx radio based on commands that come from the sbitx soapy library each of the SDR applications access.  The example below starts it in the background.  In the future this code will probably be build into the sbitx soapy library and won't be a standalone program any more.

To start it, open a new Terminal window or tab and type:

```bash
/usr/local/bin/sbitx_ctrl -v &
```
In a few seconds it should produce the output ```sbitx_ctrl listening on 127.0.0.1:9999```.  Leave that terminal window/tab open so it will continue to run.

Next, run any of the following clients.  You should probably pick the one you are most familiar with.  You should also plan to test the app with a known good SDR such as RTLSDR first to be sure it works correctly, you get audio output, etc.

## Running PiHPSDR

Some notes:
1. There are three different HPSDR icons on the desktop
  1. The original version of PiHPSDR from G0ORX
  1. The enhanced fork of PiHPSDR from DL1YCF
  1. The desktop version of PiHPSDR
1. They all operate pretty similarly

After clicking on an icon, when the app first comes up:
1. Wait if/when it says it needs to build wisdom files, this takes a while
1. If you only use sbitx then on the device selection screen go into protocols and uncheck protocols 1 and 2 and hit close so the next startup of the program is faster
1. Then, use the device selection screen to select sbitx.
1. After you see the main application window, if you want local audio then select *Menu -> RX* (with Menu on the upper right) and click on the local audio check box and then pick your sound device from the drop down -- in my case it's a usb sound card dongle that is connected to speakers

## Running GQRX

- GQRX starts slowly, especially the first time it is run
- When gqrx starts, it will present I/O Devices selector for I/Q input 
- Choose device "sBitx (ALSA IQ Bridge)" 
- It fills in the device string "driver=sbitx,soapy=2"
- Also pick your audio output device 
- In my case I have a usb sound card dongle
- Once the main window opens, use the toolbar play symbol to start the dsp
- On the right pane, Receiver tab: select AM/USB/whatever
- On the right pane, FFT tab: there are lots of settings for the panadapter / waterfall including speed, color theme, gain, zoom, etc.
- On the right pane, FFT tab: I need to lower the left *Pand. db* slider for it to show the noise floor
- On the right pane, Audio window: if you have a signal tuned and a demodulator selected then you should see a audio waveform -- if not, check squelch settings in the receiver tab

## Running SparkSDR

Notes:
- I REALLY advise using a mature SDR device to get familiar with SparkSDR (me: AirSpyHF+) and get sound output working (me: via a USB soundcard)
- After clicking on the desktop icon the first time you will probably see a blank main window
- Click on the gear icon on the top bar then select 'General Settings'
- Under 'General Settings' pick 'Station'
  - Fill in callsign/locator/antenna fields just like wsjt-x
  - Scroll to the bottom and check 'Use SoapySDR Driver'
  - If you have another supported device that is not supported under Soapy, you can enable its driver too (airspy, airspyhf, rtlsdr)
  - Under Advanced you can/should enable Enhanced Logging
    - Logs written to /home/pi/.config/m0nnb/SparkSDR2/errorlogs
  - As is says a restart is necessary so exit the app
- Upon restart if SparkSDR found a radio its details will be in the top toolbar; if not, ...
- If so, hit the round [1/0] symbol to connect to it (aka power it on)
- You should see a toolbar on the right hand side
  - This in general controls the radio
  - It confusingly has two different [...] icons, upper and lower
  - Under the upper [...] you can/should set the sample rate
    - Set it to the lowest value initally so app runs fastest
    - Click on AGC to turn it on/off
      - I found RX worked better when I turned off AGC
    - rf gain is a half-crescent shaped icon
      - click on left for less gain, right for more
  - In the next row is the frequency setting
    - click on a digit and this sets the tuning step 
    - click on top half of the digit for tune up and vice versa
  - In the next row are hourglass +/- icons for waterfall bandwidth
  - In the next row are:
    - Speaker icon: click on it to mute/unmute
    - Half-cresent 'Vol' icon: click on left for volume down, vice versa
    - Star: click access existing favorites, and/or make new ones, or to 
      save all settings
      - IMPORTANT: Star plus three pages icon saves all settings!!!
      - HANDY: it has favorites for ft8 and wspr on each band
  - Click on the lower [...] to get 'Virtual Transceiver Settings'
    on the left hand side 
    - Audio Output: 
      - For me, it found my USB dongle as 'USB Audio Device' no problem
      - I ACCIDENTALLY clicked on 'audioinjector' and since I had speakers on the sbitx it created output but it was LOUD
      - WARNING: if you have headphones into the sbitx audio out jack, take them off your head since output may be LOUD
- Upon restart if you have saved settings under Star then it will ask you if you want to load them, or load the last session

## Running CubicSDR

CubicSDR will start with a device selection and it should list sbitx as an option.  It will also let you select an audio device. After this, tune to a station, choose a "modem" (AM, FM, etc) and click on the center of the signal in the waterfall to activate the "modem".  If you located a signal it can process you should see a signal in the audio waveform window and hear sound on the audio device you've selected.  Beyond this, please consult someone familiar with CubicSDR because I have not mastered it.

## Running SDR++ 

- The program is called sdrpp on Linux
- The first time you start it there will be some setup to do
  - On the left hand toolbar, locate the Module Manager
  - If it is not opened, click the down arrow next to its name
  - You will see two columns of Name and Type values
  - Underneath those Name / Type entries you will find a row with a blank area, a drop down, and a plus sign
  - In that row:
    - Click on the blank area and type a name such as SoapySDR 
    - In the drop down, scroll till you see `soapy_source` and click on it
    - Then click on the `+` sign to add a new entry for `soapy_source`
    - Finally, close the app and restart it
- Upon (re-)starting the app the top left toolbar should have Sources on top
  - If it is not open, click on its down-arrow to open it
  - On the first drop-down below Sources choose SoapySDR as your source
  - If you only have other Soapy devices plugged in it should just find sBITX
  - Otherwise scroll through the entries till you find sBITX
- Then use ▶️ on the top left to start the radio
- Enjoy!

## TODO

Some things I hope to do in the not too distant future:
- Make sure the scripts install desktop icons in all cases 

