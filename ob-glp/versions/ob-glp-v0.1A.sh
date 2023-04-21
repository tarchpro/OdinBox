#!/bin/bash

#
#
#
#########################
### CHECK FOR COCKPIT ###
#########################
#
#
#

echo "Check if script is being run inside Cockpit"
if [[ -n $COCKPIT_SESSION ]]; then
  echo "This script cannot be run inside of Cockpit as it will restart the cockpit service."
  echo "Are you currently running this inside Cockpit? (y or n)"
  
  # Prompt user for confirmation
  while true; do
    read -p "Enter y for yes or n for no: " yn
    case $yn in
      [Yy]* ) break;;
      [Nn]* ) echo "Aborting script..."; exit;;
      * ) echo "Please answer y or n.";;
    esac
  done
fi

#
#
#
########################
### UPDATE & UPGRADE ###
########################
#
#
#

echo "Update & Upgrade System"
sudo dnf update -y
sudo dnf upgrade -y

echo "Install/Enable/Start Podman"
sudo dnf -y install podman
sudo systemctl enable podman
sudo systemctl start podman

#
#
#
###############################
### INSTALL COCKPIT SUPPORT ###
###############################
#
#
#

echo "Install Cockpit Supoprt For Podman
sudo dnf -y install cockpit-podman

echo "Restart Cockpit"
sudo systemctl restart cockpit.service

#
#
#
#######################
### PODS & NETWORKS ###
#######################
#
#
#

echo "Create The Podman Networks"
# Networks
sudo podman network create --subnet=172.100.50.254/30 nginxNET
podman network create --subnet=172.101.50.254/30 grafanaNET
podman network create --subnet=172.102.50.254/30 lokiNET
podman network create --subnet=172.103.50.254/30 promtailNET

echo "Create The Pods"
# Pods
sudo podman pod create --name Nginx --network NginxNet -p 80:80 -p 81:81 -p 443:443
podman pod create --name grafanaPOD --network grafanaNET -p 9080:9080
podman pod create --name lokiPOD --network lokiNET -p 3100:3100
podman pod create --name promtailPOD --network promtailNET -p 9080:9080

#
#
#
#############
### NGINX ###
#############
#
#
#

echo "Create a Folder for Nginx Proxy Manger Files"
sudo mkdir /NginxPM
sudo mkdir /NginxPM/letsencrypt
sudo mkdir /NginxPM/data


echo "Create the Image As Root Inside of the Pod"
sudo podman run --privileged -d --name=nginx --pod=nginxPOD -v /NginxPM/data:/data -v /NginxPM/letsencrypt:/etc/letsencrypt docker.io/jc21/nginx-proxy-manager:latest
#######################################################
#####    NOTE THIS IS NOT RECOMMNEDED PRACTICE    #####
##### IT IS REQUIRED TO RUN THE PROXY WITH PODMAN #####
#######################################################


echo "Nginx Sucessfully Installed. Firewall Ports 80, 81, 443 now direct to the pod 'NginxPM'. Go to 'http://host:81' to setup Nginx Proxy Manager. Default username: admin@example.com Default Password: changeme"

#
#
#
###############
### GRAFANA ###
###############
#
#
#

echo "Create Grafana Pod Inside The Pod"
podman run -d --name=grafana --pod=grafanaPOD docker.io/grafana/grafana

echo "Grafana Sucessfully Installed. This service will not be available until the tproxy is setup. See instructions at end of script for setup."

#
#
#
############
### LOKI ###
############
#
#
#

echo "Create Loki Pod Inside the Pod"
podman run -d --name=loki --pod=lokiPOD docker.io

echo "Loki serverf is sucessfully setup. This service is available at port 3100/tcp. Please ensure your firewall is setup appropriately."

#
#
#
################
### PROMTAIL ###
################
#
#
#

echo "Create Promtail Pod Inside the Pod"
pdoman run -d --name=promtail --pod=promtailPOD docker.io

echo "Create default promtail configuration file"

#
#
#
#################
### FIREWALL ####
#################
#
#
#

echo "Allow Loki to Promtail 9080"

echo "Allow Promtail to Loki 3100"

echo "Allow Nginx to Grafana 3000/tcp"

echo "Allow Grafana to Loki 3100"

echo "Allow Grafana to Promtail 9080"

#
#
#
##########################
### SETUP INSTRUCTIONS ###
##########################
#
#
#

##
##
##
####################################
###### ARGUMENTS FOR BOLD TEXT #####
####################################
##
##
##

bold=$(tput bold)
normal=$(tput sgr0)

###
###
###
#########################################
######### FIREWALL INSTRUCTIONS #########
#########################################
###
###
###

echo -e "\
${bold}----#####-----#####----Setup Instructions-----#####-----#####-----${normal} \n\
\n\
${bold}-----------------------------FIREWALL OPEN-----------------------------${normal} \n\
Open the following ports on your \n\
firewall to the machine: \n\
${bold}80/TCP${normal}- HTTP \n\
${bold}81/TCP${normal} - Nginx Proxy Manager In Container nginx. This is a Web GUI For managing Nginx \n\
${bold}443/TCP${normal} - HTTPS \n\
${bold}9080/TCP${normal} - Promtail Log Collector in container promtail. This service collects logs forwarded to it from external clients. \n\
${bold}9090/TCP${normal} - HTTPS Port for the Cockpit Interface. This is recommended for managing the server remotely as it provides simple management of podman pods. \n\
\n\
\n\
${bold}----------------------------FIREWALL CLOSE----------------------------${normal} \n\
Run a network scan to ensure the Following ports on your firewall to the machine are closed as they are not necessary for management of the server and may pose a security risk. \n\
${bold}22/TCP and 22/UDP${normal} - SSH This is not required for external management as the service is running Cockpit for management which includes Command Line Interface. \n\
${bold}3100/TCP${normal} - Loki Server. This service is only required to be available locally to the containers 'grafana' and 'promtail' \n\
${bold}3000/TCP${normal} - Grafana Server. This service is only required to be available locally to the container 'nginx' \n\
\n\
\n\
" | fold -s -w 80

echo -e "\
----------------------------------------------------------------------\
\n\
\n\
" | fold -s -w 80

###
###
###
####################################################
######### NGINX PROXY MANAGER INSTRUCTIONS #########
####################################################
###
###
###

echo -e "\
${bold}-----------------------NGINX PROXY MANAGER-----------------------${normal} \n\
Go to ip address of the server on http port 81. ${bold}http://server:81${normal} and login to the web interface with the defualt credentials \n\
\n\
${bold}USERNAME:${normal}admin@example.net \n\
${bold}PASSWORD:${normal}changeme \n\
\n\
${bold}CHANGE THESE TO SOMETHING SECURE IMEDIATELY${normal} \n\
" | fold -s -w 80

####
####
####
#########################################################
############ VALIDATE THE PASSWORD IS SECURE ############
#########################################################
####
####
####

\n\
${bold}ADD GRAFANA PROXY${normal} \n\
${bold}1 - ${normal}Change your username and password to something secure, then select 'Dashboard'. From the Dashboard select the option 'Proxy Hosts' and selec 
" | fold -s -w 80
