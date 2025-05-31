---
title: "No audio from Pirate Audio (Debian Bookworm)"
date: 2025-05-31T11:06:01Z
type: "page"
showTableOfContents: true
---

# Introduction

I've been playing with the Pimoroni [Pirate Audio](https://learn.pimoroni.com/article/getting-started-with-pirate-audio) board as a potential alarm clock to tie into Home Assistant. I'm running Debian 12 (bookworm) and have been trying to get the audio to play something. It appears that the vc4-kms-v3d is stopping the audio from working correctly. I found that by commenting editing the following lines in the ```/boot/firmware/config.txt```, I was able to get the board to output audio consistently. Lots of people have reported problems with this in the forums, so here is my workaround:

```
# dtparm=audio=on
dtoverlay=vc4-kms-v3d,noaudio

# The install tool from Pimoroni adds the following lines. Included here for completeness.
[all]
gpio=25=op,dh
dtoverlay=hifiberry-dac
```

Full config.txt follows:

```
dtparam=spi=on
# dtparam=audio=on
camera_auto_detect=1
display_auto_detect=1
auto_initramfs=1
# Critical option noaudio 
dtoverlay=vc4-kms-v3d,noaudio
max_framebuffers=2
disable_fw_kms_setup=1
arm_64bit=1
disable_overscan=1
arm_boost=1
[cm4]
otg_mode=1

[cm5]
dtoverlay=dwc2,dr_mode=host

[all]
gpio=25=op,dh
dtoverlay=hifiberry-dac
```

I also installed the pulseaudio daemon to manage the sound output:
```
$ sudo apt-get update; sudo apt-get -y install pamixer pulseaudio pulseaudio-utils

$ dpkg -l | egrep pulseaudio
ii  gstreamer1.0-pulseaudio:arm64        1.22.0-5+rpt2+deb12u2            arm64        GStreamer plugin for PulseAudio (transitional package)
ii  pamixer                              1.6-1                            arm64        pulseaudio command line mixer
ii  pulseaudio                           16.1+dfsg1-2+rpt1                arm64        PulseAudio sound server
ii  pulseaudio-utils                     16.1+dfsg1-2+rpt1                arm64        Command line tools for the PulseAudio sound server
```

I tested using speaker-test (turn the volume down before doing this!):

```
$ speaker-test 

speaker-test 1.2.8

Playback device is default
Stream parameters are 48000Hz, S16_LE, 1 channels
Using 16 octaves of pink noise
Rate set to 48000Hz (requested 48000Hz)
Buffer size range from 192 to 2097152
Period size range from 64 to 699051
Using max buffer size 2097152
Periods = 4
was set period_size = 524288
was set buffer_size = 2097152
 0 - Front Left
Time per period = 10.990221
 0 - Front Left
Time per period = 10.975429
 0 - Front Left
Time per period = 10.976004
 0 - Front Left
```
