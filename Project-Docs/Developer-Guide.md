# OdinBox

## Purpose
Odin Box exists to help all users install tools safely and effectively. Providing visualization and simplified setups with secure defaults and after installation hardening options. 

## Philosophy
- Ensure that default installations work with as little after installation input as possible
- Ensure that the installation process has either a TUI or GUI to maximize user reach
- Ensure that all tools have clear and precise explanations to minimize user confusion
- Ensure that code base is easily redable by company security technitians to maximize oversite and enterprise usability

### VERSIONING

Odin-Box follows the default version rules from The Architect Project of #.#@.

- v **#** .#@
	
	Numbers to the left of the decimal are major versions or revisions, defined either by mandatory security or major feature updates. Examples of reasons to use a new version number:

	- A new security flaw has been discovered and that requires immediate attention and older versions should no longer be used for active environments

	- A new TUI/GUI environment has been developed for the installer, and the old one is now depreciated

	- Major new features such as adding IPv6 support or a new software addition has been added and the old version is now depreciated due to its lack of supported features

- v#. **[#]** @
	
	Numbers to the right of the decimal are minor revision numbers, defined either by addition of new optional feature, or optional feature updates. Examples of reasons to use a new revision number are:

	- An important/commonly used feature has been patched for stability and older versions have a persistent bug

	- A TUI/GUI change has occurred that is important to development, but not to the end user such as a color or font change

	- The alpha number has surpassed Z and a new revision number is now required

- v#.# **[@]**
	
	Letters to the right of the revision numbers, defined by minor revisions/improvements. Letters go from A-Z in the Roman/American English Alphabet, after Z a new minor revision number is required. Examples of reasons to use a new revision number are:

	- A container variable has changed such as a containers default going from 1.4 to 1.41

	- An update for minor stability has been issued

	- A progressive/Quality of Life improvement has been added

	- In code documentation has been updated

### LANGUAGES & TOOLS

All Projects are written in bash. Whiptail is used as the TUI creation tool. The project is open to other tools for TUI systems, but we remain commited to basic BASH scripting for maintaining end user reviewability.

All projects that are containerized must be done with Podman, we are not supporting Docker going forward due to the security improvments of rootless and daemonless containerization tools. Some tools will require making a VM image on the machine, these tools will be distributed as seperate iso images with installers to ensure everything works correctly and will not be included in the ob-combined installer for this reason.

### SUB-PROJECTS

The currently supported and approved sub-projects are:

- ob-combined [Large Installer For Multiple Projects]
- ob-dashy [Dashy Web Dashboard Service]
- ob-glp [Grafana Loki Promtail Server for Log Management]
- ob-netbox [Netbox IPAM and network management tool]
- ob-nextcloud [NextCloud Personal Cloud Service]
- ob-nginxpm [Nginx Proxy Manager, Web Server for managing Nginx Proxy Setups]
- ob-pihole [PiHole DNS Server]
- ob-securityonion [Security Onion Security Tools]
- ob-snipeit [Snipe-IT hardware management solution
- ob-strapi [Strapi Headless CMS tool with database]
- ob-zabbix [Zabbix Network Monitoring Tool]
	
If you would like to add additional software please contact a project owner throught their contact section of their profile. Adding new sub-projects requires provisioning assets such as private IP address in the subnet map and roadmapping. We welcome new software additions.

### ROAD MAP

**Version 0.0A** refers to the development stage of all ob’s and the sub-projects progress upwards until reads for launch of 1.0A

**Version 1.0A** is the first official, fully functional stage of an ob containing a working and fully featured installer for the software.

**Version 2.0A** advances on v1 by including internal container hardening practices.

