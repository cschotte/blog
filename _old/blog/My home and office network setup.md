---
title: "My Home and Office Network Setup"
date: 2020-05-18
tags: ["UniFi", "Wi-Fi", "Internet"]
draft: false
---

Working from home, I use [Microsoft Teams](https://teams.microsoft.com/) for online meetings. Some of my colleges and customers have an unreliable Internet connection at their homes. Most of the time the problems are with their Wi-Fi what results in audio or video dropouts during online meetings. In this blog post, I outline my home and office network and Internet setup for a fast and rock-solid connection.

## Internet

In the Netherlands we are blest with fast and affordable internet, we have options like cable, fiber, and VSDL. For my home and office, I use a 500/500 Mbit fiber connection from my local ISP (KPN). Running [Speedtest](https://www.speedtest.net/) and [Fast](https://fast.com/) (from Netflix) gives me a good understanding of how fast my Internet speed is.

![Speedtest](/media/UniFi_speedtest.png)

## Networking equipment

All my networking equipment is from [Ubiquiti](https://www.ui.com/) and I use their [UniFi](https://www.ui.com/products/#unifi) product line. My choice  for Ubiquiti/UniFi comes from the experience I had in the past. UniFi gives me professional control over my network and still is easy to use. You need at least a Security Gateway (USG), a Switch with PoE and one or more Access Points (AP) to start. The control software you can run on your computer, but I recommend to use a Cloud Key (Gen2). All my AP's are getting their power from the network cable (Power over Ethernet), so no need to have additional power cables. My network is fully managed using the Cloud Key (Gen2) Plus. An extra benefit is that it gives me lots of insides and it is easy to manage.

![Network devices](/media/UniFi_network_devices.png)

Normally the Internet connection comes with a modem and built-in Wi-Fi router that is placed nearby the front door. Not the best place in the house and fare away from the office. These ‘modems’ are also not the best quality and have a limited Wi-Fi range. If possible remove this device from your network or set it in bridge mode. [Read more about how](/blog/kpn-fiber-connection-with-ubiquiti-usg-iptv-and-ipv6/).

![Basic network](/media/UniFi_basic_network.png)

## Networking cables

When building my house last year, I wired all my rooms and ceilings with **CAT6 UTP** networking cables. All networking cables come together nearby the front door ware also the Internet connection (fiber) is entering the house. I created a mini networking cabinet where I have my switching and security gateway networking equipment.

![My network rack cabinet](/media/UniFi_network_rack_cabinet.jpg)

Colors I used for the patch cables are:
- **Red** Internet (public IP)
- **Green** Local network (firewalled)
- **Yellow** patch cables to devices and APs

![Network topology](/media/UniFi_network_topology.png)

## Access points

In the rest of the house, I have multiple access points and the office is fully wired. This gives me very good Wi-Fi coverage in and around the house. Using the Map functionality in the controller software I can check where I have blind spots in my house. (Below picture is an example)

![Wi-Fi Floorplan](/media/UniFi_floorplan.png)

## Optimize Wi-Fi throughput

To get the maximum Wi-Fi throughput, you need to change the Channel Width. I did this only for the 5G radios where I changed the Channel Width to VHT80 or VHT160. By default the Channel Width is VHT40 what is good for dense networks with a lot of clients, like a public place (what is not my home).

![Wi-Fi AP Channel Width](/media/UniFi_AP_ChannelWidth.png)