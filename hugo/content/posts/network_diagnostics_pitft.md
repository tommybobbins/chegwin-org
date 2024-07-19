---
title: "Network_diagnostics_pitft"
date: 2024-04-07T16:20:16+01:00
draft: false
type: "post"
---

# Network Diagnostics PiTFT

I was asked to create a quick tool to perform a set of basic connectivity checks for field engineers who are unable to get servers to connect to the network. The engineers often don't want to fire up their laptops to check Ethernet, IP, DNS and HTTP checks. I wrote a tool to run on the ethernet enabled RPis to perform these checks using an Adafruit [PiTFT](https://learn.adafruit.com/adafruit-mini-pitft-135x240-color-tft-add-on-for-raspberry-pi/python-setup).

The source code and screenshots can be found on [github](https://github.com/tommybobbins/minipitft_netdiagnostic).
