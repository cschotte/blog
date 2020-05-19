---
title: "My Home and Office Network Setup"
date: 2020-05-18
tags: ["UniFi", "Wi-Fi", "Internet"]
draft: false
---

Working from home, I use a lot of [Microsoft Teams](https://teams.microsoft.com/) for online meetings. To my surprise, some of my colleges have an unreliable internet connection at their home. Most of the time the problems are with their Wi-Fi what results in audio or video dropouts during online meetings. In this blog post, I outline my home and office network and internet setup for a fast and reliable connection.

In the Netherlands we are blest with fast and affordable internet, we have options like cable, fiber, and VSDL. For my home and office, I use a 500/500 Mbit fiber connection from my local ISP (KPN). Running [Speedtest](https://www.speedtest.net/) and [Fast](https://fast.com/) (from Netflix) gives me a good understanding how fast my  internet speed is.

![Speedtest](/media/UniFi_speedtest.png)

All my networking equipment is from [Ubiquiti](https://www.ui.com/) and I use their [UniFi](https://www.ui.com/products/#unifi) product line.

![network devices](/media/UniFi_network_devices.png)

Normally the internet connection comes with a modem and built-in Wi-Fi router what is placed nearby the front door. Not the best place in the house and fare away from the office. These ‘modems’ are also not the best quality and have a limited Wi-Fi range.

![basic network](/media/UniFi_basic_network.png)

When building my house last year, I wired all my rooms and ceilings with CAT6 UTP networking cables. All networking cables come together nearby the front door ware also the internet connection (fiber) is entering the house. I created a mini networking cabinet where I have my switching and security gateway networking equipment.

![My network rack cabinet](/media/UniFi_network_rack_cabinet.jpg)

Colors I used for the patch cables are:
- **Red** Internet (public IP)
- **Green** Local network (firewalled)
- **Yellow** patch cables to devices and APs

![network topology](/media/UniFi_network_topology.png)

In the rest of the house, I have multiple access points and the office is fully wired. This gives me very good Wi-Fi coverage in and around the house.

![Wi-Fi floorplan](/media/UniFi_floorplan.png)

My network is fully managed using the Cloud Key (Gen2) Plus. An extra benefit is that it gives me lots of insides and it is easy to manage.

