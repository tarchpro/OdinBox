#!/bin/bash

### CHECK IF RUNNING AS ROOT
    if [ id -u 0 ]
    then
        if rpm -a newt
        then 
        whiptail --msgbox "Script must be run with SUDO or ROOT priveleges" 7 55
        exit
        else
        echo "Script must run with SUDO privileges"
        fi
    exit
    fi

### CHECK FOR DIALOG && INSTALL IF NOT THERE
    if rpm -q newt
        then
        WHIPTAIL_INSTALLED="yes"
        else
        dnf install newt -y
        WHIPTAIL_INSTALLED="no"
    fi

### EULA

whiptail --yesno \
"The following installer will make modifications to your system. By selecting yes \
you agree that you have permission to make these modifications and that you have read \
and understand the script that is about to run. \
\n
Additionally, you agree that you and \
only you are responsible for anything that may occur as a result of running this script." \
20 60 --yes-button AGREE --no-button DISAGREE

if [ echo $? 1 ]
    then   
    exit 0
fi

### CHECK FOR COCKPIT ADD-ONS && PODMAND

    # WHIPTAIL GAGUE
    {
        # COCKPIT-PODMAN
        if rpm -q cockpit-podman
            then
            GARBAGE="1"
            else
            dnf -y install cockpit-podman
        fi

        # COCKPIT-NAVIGATOR
        if rpm -q cockpit-navigator
            then
            GARBAGE="1"
            else
            dnf -y install cockpit-navigator
        fi

        # PODMAN
        if rpm -q podman
            then
            GARBAGE="1"
            else
            dnf -y install podman
        fi
    } | whiptail --title \
    "Start-Up Progress" \
    --gague "Installing/Checking standard packages cockpit-podman cockpit-navigator podman" \
    10 60 0

### SET INSTALL DIRECTORY

whiptail --yesno \
"The recommended directory for all OdinBox components is /var/ob and is selected by default.\n
Would you like to select a different location?" 20 60

if [ echo $? 0 ]
    then
    INSTALL_DIRECTORY=$(whiptail --inputbox "Please enter the desired directory" 20 60) 
    else
    INSTALL_DIRECTORY="/var/ob"
fi

### MAKE INSTALL DIRECTORIES

    if [[ "$INSTALL_DIRECTORY" == "/var/ob" ]]
        then
        mkdir -p $INSTALL_DIRECTORY/snipeit1/mariadb/config
        mkdir -p $INSTALL_DIRECTORY/snipteit1/snipeit/config
        else
        mkdir -p $INSTALL_DIRECTORY/snipeit/mariadb/config
        mkdir -p $INSTALL_DIRECTORY/snipeit/snipeit/config
    fi

### SET POD/CONTAINER NAMES

# DEFAULT VARIABLES
NETWORK="snipeit1NET"
PODNAME="snipeitPOD"
DB_CONTAINER="snipeit1_mariadb"
SNIPE_CONTAINER="snipeit1_snipeit"

# MODIFY DEFAULTS YES/NO
whiptail --yesno \
"The default names are: \n
POD_NETWORK = snipeit1NET \n
PODMAN_POD = snipeit1POD \n
DATABASE_CONTAINER = snipeit1_mariadb \n
SNIPE-IT_Container = snipeit1_snipeit \n
\n
Would you like to alter any of these parameters?"

# MODIFY VARIALBES YES
while [ 1 ]

if [ echo $? 0 ]
then
whiptail --title "Modify Defaults" --menu "" 16 80 4 \
"PODMAN_NETWORK" "$NETWORK" \
"PODMAN_POD" "$PODNAME" \
"DATABASE_CONTAINER" "$DB_CONTAINER" \
"SNIPE-IT_CONTAINER" "$SNIPE_CONTAINER" 

fi