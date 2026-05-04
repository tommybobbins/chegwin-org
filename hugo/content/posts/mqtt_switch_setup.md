---
title: "MQTT Home Assistant Switch setup"
date: "2026-05-04"
author: "Tim Gibbon"
tags: ["mqtt","mosquitto_pub","mosquitto_sub","rpi"]
keywords: ["mqtt","mosquitto_pub","mosquitto_sub","rpi"] 
description : "Configuring Manual switches in MQTT and Home assistant"
type: "post"
showTableOfContents: true
---

# Setting up MQTT switches in Home Assistant

A work in progress

## Introduction

I wanted to create some switches in Home Assistant already controlled via a Raspberry Pi. The Pi uses a relay board and sequences of button presses to open/close 3 velux windows.
The relay board is connected to a proprietary Velux remote control and simulates button presses. It's horrible, but it's been working for 11 years.

Original concept video: ![Raspberry Pi Velux opener](https://www.youtube.com/watch?v=KOUMUorDWvA)

## Pre-requisites

Create a user bobbins-client on Home assistant, we will use wibble-bibble-chegwin in our examples

## Porting to MQTT

For each of the 3 Veluxes, I needed to create switches in MQTT, so I used the following configuration incrementing 1,2,3

```
{
        "unique_id": "velux_switch_1",
        "name": "Velux Switch 1",
        "state_topic": "homeassistant/switch/velux/1",
        "command_topic": "homeassistant/switch/velux/1/set",
        "availability": [
          {
            "topic": "homeassistant/switch/velux/1/available"
          }
        ],
        "payload_on": "ON",
        "payload_off": "OFF",
        "state_on": "ON",
        "state_off": "OFF",
        "optimistic": "true",
        "qos": 0,
        "retain": "true"
}
```
I saved this as config_payload_veluxswitch1.json and then created the switch and set it as online

```
mosquitto_pub -h homeassistant.local -u bobbins-client -P wibble-bibble-chegwin -t "homeassistant/switch/velux/1/config" -f config_payload_veluxswitch1.json
mosquitto_pub -h homeassistant.local -u bobbins-client -P wibble-bibble-chegwin -t "homeassistant/switch/velux/1/available" -m "online"
```

The devices should then show up in MQTT in Home Assistant. I run this as a cronjob every 8 hours so if HA reboots, the devices re-register.

## Test Switch on/off

```
mosquitto_pub -h homeassistant.local -u bobbins-client -P wibble-bibble-chegwin -t "homeassistant/switch/velux/1" -m "ON"
mosquitto_pub -h homeassistant.local -u bobbins-client -P wibble-bibble-chegwin -t "homeassistant/switch/velux/1" -m "OFF"
```

## Read last state of the Switch CLI

```
mosquitto_sub -h homeassistant.local -u bobbins-client -P wibble-bibble-chegwin -t "homeassistant/switch/velux/1/set" -C 1
```

## Python Read last state of the switch

```
import paho.mqtt.subscribe as subscribe
from paho.mqtt.client import Client

def return_topic(topic):
    msg = subscribe.simple(topic, msg_count=1, retained=True,
        hostname=mqtt_broker,
        port=mqtt_port,
        auth={'username':mqtt_username,'password':mqtt_password})
    return msg.topic, msg.payload.decode("utf-8")


switchtopic, switch = return_topic("homeassistant/switch/velux/1/set")


```

## Python Write value of the switch

```
import paho.mqtt.publish as publish
from paho.mqtt.client import Client

def publish_topic(topic,payload):
    try:
        msg = publish.single(topic, payload=payload,
            hostname=mqtt_broker,
            port=mqtt_port,
            auth={'username':mqtt_username,'password':mqtt_password})
        logging.info(f"Sending {topic} {payload}")
    except:
        logging.info(f"Failed to send {topic} {payload}")

publish_topic('homeassistant/switch/velux/3','ON')

```
