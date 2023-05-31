# Alex Lavallee's IaC (Infrastructure as Code)
# Parts
1. [Netboot](#netboot)
1. [Ansible](#ansible)
# Netboot
This folder (after running `bootstrap.sh`) contains all the files to allow the network booting and automatic installing of Debian 11 Bullseye and Ubuntu 20.04 LTS Focal Fossa. This works by using a TFTP server to serve grub and related config files followed by a HTTP server serving debian and ubuntu pressed files.
# Ansible
This folder contains Ansible tasks to install all the services that I use in my homelab. The current list is: Caddy (Reverse Proxy), Heimdall (Service Organizer), Immich (Photo Storage), Jellyfin (Media Streaming Server with hardware transcoding setup), Samba (Time Machine Backups), SSHca (SSH Certificate Authority to allow ssh authentication to all services, Made by Me (-; ), Transmission (Torrenting of Linux ISOs for other services), and Unifi (Managing home AP). These tasks will go directly from 3 newly installed Debian Bullseye servers to Proxmox VE hosts with 7 LXC containers running the services listed above.