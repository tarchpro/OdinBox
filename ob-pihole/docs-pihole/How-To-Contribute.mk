# How To Contribute To ob-pihole
1. Install most recent version of non-beta Fedora Server
2. Update/Upgrade the system to newest versions of packages:
	- sudo apt update && sudo apt upgrade -y
3. Install/Enable the following packages:
	- sudo dnf install podman && sudo systemctl enable podman
	- sudo dnf install cockpit-podman
4. Clone the git repository to your computer to work on the files