# secure-remote-infrastructure
A full detailed *technical* guide to how I was able to configure infrastructure that allows me to connect to my home LAN



# Secure Remote Infrastructure with Raspberry Pi, Tailscale, and Wake-on-LAN

## Overview

This project documents the design and implementation of a secure remote access infrastructure built using:

- Raspberry Pi (Linux gateway)
- Tailscale (encrypted overlay network)
- Windows Pro (RDP host)
- Wake-on-LAN (BIOS-level power control)
- Remmina (Linux RDP client)

The goal was to enable secure remote desktop access from anywhere without exposing any ports to the public internet, without configuring router port forwarding, and without relying on a static public IP address.

This system allows:

1. Secure encrypted access into a home LAN using Tailscale subnet routing
2. Remote power-on of a desktop machine using Wake-on-LAN
3. RDP access to a Windows desktop over a private routed network
4. Automation of the wake-and-connect workflow

---

## Architecture

The system consists of:

- A Linux laptop acting as the remote client
- A Raspberry Pi configured as a Tailscale subnet router
- A Windows Pro desktop inside a private LAN
- A home router providing DHCP and local routing

High-level flow:

Remote laptop connects to Tailscale  
Raspberry Pi advertises the local subnet  
Laptop accepts subnet routes  
RDP traffic flows securely through the encrypted tunnel  
Wake-on-LAN packets are sent from the Pi to power on the desktop  

No services are exposed to the public internet.

---

## Technologies Used

- Raspberry Pi OS Lite
- Tailscale (subnet routing mode)
- Windows 10/11 Pro
- Wake-on-LAN
- Remmina (Linux RDP client)
- BIOS configuration for PCI-E wake

---

## Key Configuration Steps

### 1. Raspberry Pi Setup

- Flashed Raspberry Pi OS Lite
- Enabled SSH on first boot
- Installed Tailscale
- Enabled subnet routing:

sudo tailscale up --ssh --advertise-routes=(my LAN subnet)


- Enabled IP forwarding in Linux:

net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1


---

### 2. Tailscale Route Acceptance

On the remote client:
sudo tailscale up --accept-routes


Approved subnet routes in Tailscale admin panel.

This allowed secure access to LAN devices without port forwarding.

---

### 3. Windows Remote Desktop Configuration

- Confirmed Windows Pro edition
- Enabled Remote Desktop
- Verified port 3389 was listening
- Set network profile to Private
- Confirmed firewall rules allowed RDP
- Resolved Windows Hello PIN vs password authentication issue

---

### 4. Wake-on-LAN Configuration

BIOS configuration:

- Resume by PCI-E Device → Enabled
- ErP → Disabled
- Deep Sleep → Disabled

Windows NIC configuration:

- Allow device to wake computer
- Only allow magic packet
- Wake on Magic Packet enabled

Installed wakeonlan on Raspberry Pi:
sudo apt install wakeonlan


---

### 5. Automation Script

Created a helper script to simplify wake process.

See `wakepc.sh`.

Replace the MAC address with the target device MAC.

Make executable:

chmod +x wakepc.sh


Optional alias:

alias wakepc="~/wakepc.sh"

**Security Design Decisions**

  This project avoids common insecure remote access practices:
    
    No port forwarding
    
    No public RDP exposure
    
    No open 3389 on WAN
    
    No reliance on static public IP
    
    No direct router configuration for remote access
    
  Access is restricted to authenticated Tailscale devices only.
  
  Wake-on-LAN is confined to the internal LAN.
  
  RDP traffic flows only inside the encrypted overlay network.

**Troubleshooting Lessons Learned**

**SSH Not Enabled
**
Raspberry Pi OS Lite requires SSH to be enabled manually or via Imager advanced settings.

**Incorrect IP Address**

  Used network scanning tools to identify the correct LAN IP.

**RDP Not Listening
** - 
  Verified with:
  
  netstat -an | find "3389"

**Windows Hello PIN Issue
** - 
RDP requires actual account password, not PIN authentication.

**Subnet Routing Not Working
** - 
Resolved by enabling:

  --accept-routes

**Wake-on-LAN Failing**

  Resolved by enabling "Resume by PCI-E Device" in BIOS.
  Ethernet port must retain standby power for WOL to function.

**Final Workflow**

    Connect remote laptop to Tailscale
    
    SSH into Raspberry Pi
    
    Run wakepc
    
    Wait for system boot
    
    Connect via RDP to internal LAN IP
**
What This Project Demonstrates**

    Overlay network architecture
    
    Subnet routing design
    
    Secure remote access implementation
    
    BIOS-level power configuration
    
    Network troubleshooting
    
    Layered security thinking
    
    Automation and workflow optimization

This is not simply enabling remote desktop.
It is building and securing remote infrastructure from firmware to application layer.
