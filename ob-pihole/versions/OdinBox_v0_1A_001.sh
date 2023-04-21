#!/bin/bash

######################
### CHECK FOR SUDO ###
######################

# Check if script is being run with sudo privileges
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run with sudo privileges."
    exit 1
fi

#########################
### CHECK FOR COCKPIT ###
#########################

echo "This script cannot be run inside of Cockpit as it will restart the cockpit service."
echo "Are you currently running this inside Cockpit? (y or n)"
  
# Prompt user for confirmation
  while true; do
    read -p "Enter y for yes or n for no: " yn
    case $yn in
      [Yy]* ) echo "Aborting script..."; exit;; # If user answers yes, stop the script.
      [Nn]* ) break;; # If user answers no, continue with the rest of the script.
      * ) echo "Please answer y or n.";;
    esac
  done

########################
### UPDATE & UPGRADE ###
########################

echo "Update & Upgrade System"
sudo dnf update -y
sudo dnf upgrade -y

###################################
### INSTALL/ENABLE/START PODMAN ###
###################################

echo "Install/Enable/Start Podman"
sudo dnf -y install podman
sudo systemctl enable --now podman.service
sudo systemctl enable --now podman-restart.service
sudo systemctl enable --now podman-clean-transient.service
sudo systemctl enable --now podman-restart.service


# Wait 10 seconds for podman to start fully for cockpit
echo "Wait 10 seconds for process to start"
sleep 10

###############################
### INSTALL COCKPIT SUPPORT ###
###############################

echo "Install Cockpit Supoprt For Podman"
sudo dnf -y install cockpit-podman

echo "Restart Cockpit"
sudo systemctl restart cockpit.service

############################
### SET VARIABLE OF USER ###
############################

username=$(logname)

###########################
### SELECT INSTALL TYPE ###
###########################
#
# Prompt the user to select one or more options
#cho "Please select one or more options:"
#cho "1. Default/Install_All"
#cho "2. Dashboard"
#cho "3. AD/DC (FreeIPA)"
#echo "4. NextCloud"
#cho "5. Log Server (Grafana/Loki)"
#cho "6. Server Monitoring (Grafana/Prometheus)"
#echo "7. IPAM/Asset Inventory (NetBox)"
#echo "8. LocalDNS (PiHole)"
#read -p "Enter your choice(s) separated by commas (e.g. 1,2,3): " choices
#
# Split the user's choices into an array
#IFS=',' read -r -a choices_array <<< "$choices"
#
# Loop through the array of choices and perform actions based on the selected options
#for choice in "${choices_array[@]}"
#do
#  case $choice in
#    1)
#      echo "Installing all packages..."
#      # Run code to install all packages
#      ;;
#    2)
#      echo "Installing Dashboard..."
#     # Run code to install Dashboard
#      ;;
#    3)
#      echo "Installing AD/DC (FreeIPA)..."
#      # Run code to install AD/DC (FreeIPA)
#      ;;
#   4)
#     echo "Installing NextCloud..."
#     # Run code to install NextCloud
#      ;;
#   5)
#     echo "Installing Log Server (Grafana/Loki)..."
#    # Run code to install Log Server (Grafana/Loki)
#      ;;
#    6)
#      echo "Installing Server Monitoring (Grafana/Prometheus)..."
#      # Run code to install Server Monitoring (Grafana/Prometheus)
#     ;;
#   7)
#      echo "Installing IPAM/Asset Inventory (NetBox)..."
#     # Run code to install IPAM/Asset Inventory (NetBox)
#      ;;
#   8)
#     echo "Installing LocalDNS (PiHole)..."
#      # Run code to install LocalDNS (PiHole)
#      ;;
#   *)
#     echo "Invalid choice: $choice"
#     ;;
# esac
#done
#
#########################################################
######### BELOW IS DEFAULT/INSTALL_ALL OPTION 1 #########
#########################################################
#
#################################################################
### ALLOW NON ROOT TO BIND PORTS 53,80,81,123,443,464,389,636 ###
#################################################################

sh -c 'echo " "net.ipv4.ip_unprivileged_port_start=53" >> /etc/sysctl.conf'
sh -c 'echo " "net.ipv4.ip_unprivileged_port_start=80" >> /etc/sysctl.conf'
sh -c 'echo " "net.ipv4.ip_unprivileged_port_start=81" >> /etc/sysctl.conf'
sh -c 'echo " "net.ipv4.ip_unprivileged_port_start=123" >> /etc/sysctl.conf'
sh -c 'echo " "net.ipv4.ip_unprivileged_port_start=389" >> /etc/sysctl.conf'
sh -c 'echo " "net.ipv4.ip_unprivileged_port_start=443" >> /etc/sysctl.conf'
sh -c 'echo " "net.ipv4.ip_unprivileged_port_start=464" >> /etc/sysctl.conf'
sh -c 'echo " "net.ipv4.ip_unprivileged_port_start=636" >> /etc/sysctl.conf'
systemctl -p

##############################
### CREATE PODMAN NETWORKS ###
##############################

# Network Variables = Subnet
masterproxyNETsubnet=$(10.0.0.1/24)
masterproxyNETgateway=$(10.0.0.254)
dashboardNETsubnet=$(10.0.1.1/24)
dashboardNETgateway=$(10.0.1.254)
freeipaNETsubnet=$(10.0.2.1/24)
freeipaNETgatway=$(10.0.2.254)
nextcloudNETsubnet=$(10.0.3.1/24)
nextcloudNETgatway=$(10.0.3.254)
glpNETsubnet=$(10.0.4.1/24)
glpNETgateway=$(10.0.4.254)
gpNETsubnet=$(10.0.5.1/24)
gpNETgateway=$(10.0.5.254)
netboxNETsubnet=$(10.0.6.1/24)
netboxNETgateway=$(10.0.6.254)
pihole1NETsubnet=$(10.0.7.1/24)
pihole1NETgateway=$(10.0.7.254)
pihole2NETsubnet=$(10.0.8.1/24)
pihole2NETgateway=$(10.0.8.254)

# Set DNS Servers
userDNS=$(9.9.9.9)
serverDNS=$(9.9.9.9)
externalDNS=$(9.9.9.9)

# Master Proxy Network
echo "Create masterproxyNET"
sudo -u $username podman network create --subnet $masterproxyNETsubnet --gateway $masterproxyNETsubnet --dns $serverDNS --name masterproxyNET

# Dashboard Network
echo "Create dashboardNET"
sudo -u $username podman network create --subnet $dashboardNETsubnet --gateway $dashboardNETgateway --dns $serverDNS --name dashboardNET

# FreeIPA Network
echo "Create freeipaNET"
sudo -u $username podman network create --subnet $freeipaNETsubnet --gateway $freeipaNETgatway --dns $serverDNS --name freeipaNET

# NextCloud Network
echo "Create nextcloudNET"
sudo -u $username podman network create --subnet $nextcloudNETsubnet --gateway $nextcloudNETgatway --dns $serverDNS --name nextcloudNET

# Grafana Loki Promtail Network
echo "Create glpNET"
sudo -u $username podman network create --subnet $glpNETsubnet --gateway $glpNETsubnet --dns $serverDNS --name glpNET

# NetBox Network
echo "Create NetBox Network"
sudo -u $username podman network create --subnet $netboxNETsubnet --gateway $glpNETsubnet --dns $serverDNS --name netboxNET

# PiHole 1 Network - Server DNS
echo "Create PiHole Network for Local Server's DNS"
sudo -u $username podman network create --subnet $pihole1NETsubnet --gateway $pihole2NETgateway --dns $externalDNS --name pihole1NET

# PiHole 2 Network - User DNS
echo "Create PiHole Netowrk for User Network"
sudo -u $username podman network create --subet $pihole2NETsubnet --gateway $pihole2NETgateway --dns $externalDNS --name pihole2NET

##########################
### CREATE PODMAN PODS ###
##########################

# Master Proxy - Nginx Proxy Manager
echo "Master proxy has no Pod"

# Dashboard
echo "Create dashboardPOD"
sudo -u $username podman pod create \
    --name dashboardPOD \
    --network dashboardNET

# FreeIPA
echo "Create freeipaPOD, bind it to freeipaNET, and bind ports 389/TCP 636/TCP 88/TCP/UDP 464/TCP/UDP 123/UDP 53/TCP/UDP"
sudo -u $username podman pod create \
    --name freeipaPOD \
    --network freeipaNET \
    -p 389:389 \
    -p 636:636 \
    -p 88:88/tcp \
    -p 88:88/udp \
    -p 464:464/tcp \
    -p 464:464/udp \
    -p 123:123/udp \
    -p 53:53/udp \
    -p 53:53/tcp

# NextCloud
echo "Create nextcloudPOD, bind it to nextcloudNET"
sudo -u $username podman pod create \
    --name nextcloudPOD \
    --network nextcloudNET \
    -p 3478:3478/udp \
    -p 3478:3478 \
    -p 5349:5349 \
    -p 5349:5349/udp \
    -p 49152-65535:49152-65535/udp

# Netbox
echo "Create netboxPOD, bind it to netboxNET"
sudo -u $username podman pod create \
    --name netboxPOD \
    --network netboxNET

# PiHole 1 - Server DNS
echo "Create pihole1POD, bind it to pihole1NET"
sudo -u $username podman pod create \
    --name pihole1POD \
    --network pihole1NET

# PiHole 2 - User DNS
echo "Create pihole2POD, bind it to pihole2NET"
sudo -u $username podman pod create \
    --name pihole2POD \
    --network pihole2NET

####################################################
### CREATE STORAGE ROOT DIRECTORY FOR CONTAINERS ###
####################################################

# Create File 'odinbox' in root directory
echo "Create file 'odinbox' in root directory"
mkdir /ob

#######################################
### CREATE MASTER PROXY POD SERVICE ###
#######################################

# Create container
echo "Create container masterproxy, bind it to masterproxyNET"
sudo -u $username podman run \
    --name masterproxy \
    --network masterproxyNET \
    --dns $serverDNS \
    --ip 10.0.0.1 \
    -p 80:80/tcp \
    -p 81:81/tcp \
    -p 443:443/tcp \
    docker.io/jc21/nginx-proxy-manager:latest

####################################
### CREATE DASHBOARD POD SERVICE ###
####################################

# Create Container
echo "Create container dashboard1, bind it dashboardPOD"
sudo -u $username podman run \
    --name dashboard1 \
    --pod dashboardPOD \
    docker.io#####UNKNOWN TOOL

##################################
### CREATE FREEIPA POD SERVICE ###
##################################

# Create Configuration Data Folder
echo "Create and assign ownership /ob/freeipa/ipa-data"
mkdir /ob/freeipa
mkdir /ob/freeipa/ipa-data
chown $username /ob/freeipa/ipa-data
chown $username /ob/freeipa

# Create Container
echo "Create container freeipa1, bind it freeipaPOD"
sudo -u $username podman run \
     --name freeipa1 \
     --pod freeipaPOD \
     -v /ob/freeipa/ipa-data:/data:Z \
     docker.io/freeipa/freeipa-server:rocky-9

####################################
### CREATE NEXTCLOUD POD SERVICE ###
####################################

# Create Data Folder
echo "Create and assign ownership of configuration files"
mkdir -p /ob/nextcloud/{apps,config,data,themes}
chown -R $username /ob/nextcloud

# Create Next Cloud Server
echo "Create container nextcloud1, bind it to nextcloudPOD"
sudo -u $username podman run \
    --name nextcloud1 \
    --pod nextcloudPOD \
    -v /ob/nextcloud/:/var/www/html/ \
	-v /ob/nextcloud/apps:/var/www/html/custom_apps \
	-v /ob/nextcloud/config:/var/www/html/config \
	-v /ob/nextcloud/data:/var/www/html/data \
	-v /ob/nextcloud/themes/:/var/www/html/themes/ \
    docker.io/nextcloud:fpm-alpine

# Create Only Office Server
echo "Create Open Office Server For Document Editing"
sudo -u $username podman run \
    --name onlyoffice1 \
    --pod nextcloudPOD \
    --shm-size=512m \
    -e VNC_PW=password \
    docker.io/kasmweb/only-office:1.12.0

# Create STUN Server for Reverse NAT Managmenet
echo "Create Stun/Turn Server bind it to nextcloudPOD"
sudu -u $username podman run \
    --name stunturn1 \
    --pod nextcloudPOD \
    coturn/coturn

################################################
### CREATE GRAFANA LOKI PROMTAIL POD SERVICE ###
################################################

# Create Grafana
echo "Create Grafana container, bind it to glpPOD"
sudu -u $username podman run -d --name=grafana1 \
    --pod=glpPOD \
    --restart=unless-stopped \
    docker.io/grafana/grafana

# Create Folders For Persisting Loki Data
echo "Create a Folder for Persisting Data In Loki & make current user the owner of the file"
mkdir -p /ob/loki/{data,config}
sudo chown -R $username /ob/loki

# Create Loki Configuration File
echo "Create Loki Configuration Yaml File"

cat << EOF | tee /ob/loki/config/local-config.yaml > /dev/null
auth_enabled: false

server:
  http_listen_port: 3100
  grpc_listen_port: 9096

common:
  instance_addr: 127.0.0.1
  path_prefix: /tmp/loki
  storage:
    filesystem:
      chunks_directory: /tmp/loki/chunks
      rules_directory: /tmp/loki/rules
  replication_factor: 1
  ring:
    kvstore:
      store: inmemory

query_range:
  results_cache:
    cache:
      embedded_cache:
        enabled: true
        max_size_mb: 100

schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

ruler:
  alertmanager_url: http://127.0.0.1:9093

    # By default, Loki will send anonymous, but uniquely-identifiable usage and configuration
    # analytics to Grafana Labs. These statistics are sent to https://stats.grafana.org/
    #
    # Statistics help us better understand how Loki is used, and they show us performance
    #   levels for most users. This helps us prioritize features and documentation.
    # For more information on what's sent, look at
    # https://github.com/grafana/loki/blob/main/pkg/usagestats/stats.go
    # Refer to the buildReport method to see what goes into a report.
    #
    # If you would like to disable reporting, uncomment the following lines:
analytics:
    reporting_enabled: false
EOF
chown $username /glp/loki/config/local-config.yaml

# Create Loki
sudu -u $username echo "Install Loki container, and bind it to glpPOD"
podman run -d --name=loki1 \
    --pod=glpPOD \
    --restart=unless-stopped \
    -v /ob/loki/data:/data \
    -v /ob/loki/config/local-config.yaml:/etc/loki/local-config.yaml:z \
    docker.io/grafana/loki \
    -config.file=/etc/loki/local-config.yaml

# Create Folders For Persisting Promtail Data
echo "Create a Folder for Promtail Config and Data"
mkdir /ob/promtail
chown $username /ob/promtail

# Create Promtail Configuration YAML File
echo "Create the promtail Configuration File & Modify Owner"
cat << EOF | tee /ob/promtail/config.yaml > /dev/null
server:
  http_listen_address: 127.0.0.1
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://127.0.0.1:3100/loki/api/v1/push
  
scrape_configs:
  - job_name: system
    static_configs:
    - targets:
        - localhost
      labels:
        job: varlog
        __path__: /var/log/*log
EOF
chown $username /ob/promtail/config.yaml

# Create Promtail
echo "Create Promatail container and bind it to glpPOD"
sudu -u $username podman run -d --name=promtail1 \
    --pod=glpPOD \
    --restart=unless-stopped \
    -v /ob/promtail/config.yaml:/ob/promtail/config.yaml:z \
    docker.io/grafana/promtail \
    -config.file=/ob/promtail/config.yaml

#############################################
### CREATE GRAFANA PROMETHEUS POD SERVICE ###
#############################################

# Create Grafana
echo "Create Grafana container, bind it to gpPOD"
sudu -u $username podman run -d --name=grafana2 \
    --pod=gpPOD \
    --restart=unless-stopped \
    docker.io/grafana/grafana

# Create Folders For Persisting Prometheus Data
echo "Create Prometheus Persistence File & Modify Owner"
mkdir /ob/prometheus
sudo chmod $username /ob/prometheus

# Create Prometheus Container
ehco "Create Prometheus Container and bind it gpPOD"
sudo -u $username podman run \
    --name prometheus1 \
    -v /ob/prometheus:/opt/bitnami/prometheus/data \
    docker.io/bitnami/prometheus:latest

#################################
### CREATE NETBOX POD SERVICE ###
#################################

###############################################
### CREATE PI HOLE POD1 SERICE : SERVER DNS ###
###############################################

# Create Pi Hole : Server DNS
ehco "Create PiHole Container 1 For Server DNS, and bind it to pihole1POD"
sudo -u $username podman run \
    --name pihole1 \
    docker.io/pihole/pihole

#############################################
### CREATE PI HOLE POD1 SERICE : USER DNS ###
#############################################

# Create Pi Hole : USER DNS
ehco "Create PiHole Container 2 For User DNS, and bind it to pihole2POD"
sudo -u $username podman run \
    --name pihole2 \
    docker.io/pihole/pihole

#######################################################
######### VARIABLES TO CORRECT IN DEVELOPMENT #########
#######################################################

# Correct localDNS