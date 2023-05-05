#!/bin/bash -x

### CHECK IF RUNNING AS ROOT
    if [ $? -eq 0 ]; then
        if rpm -a newt
        then 
        whiptail --msgbox "Script must be run with SUDO or ROOT priveleges" 7 55
        exit
        else
        echo "Script must run with SUDO privileges"
        fi
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

    if [ $? -eq 1 ]
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
    --gauge "Installing/Checking standard packages cockpit-podman cockpit-navigator podman" \
    10 60 0

### SET INSTALL DIRECTORY

    whiptail --yesno \
    "The recommended directory for all OdinBox components is /var/ob and is selected by default.\n
    Would you like to select a different location?" 20 60

    if [ $? -eq 0 ]; 
        then
        INSTALL_DIRECTORY=$( (whiptail --title "INSTALL DIRECTORY" --inputbox "Please enter the desired directory" 20 60) 3>&1 1>&2 2>&3 )
        else
        INSTALL_DIRECTORY="/var/ob"
    fi

### SET POD/CONTAINER NAMES

    # DEFAULT VARIABLES
        NETWORK="snipeit1NET"
        SUBNET="10.0.6.254/24"
        GATEWAY="10.0.6.254"
        DNS="9.9.9.9"
        PODNAME="snipeit1POD"
        DB_CONTAINER="snipeit1_mariadb"
        SNIPE_CONTAINER="snipeit1_snipeit"

    # MODIFY DEFAULTS YES/NO
        whiptail --yesno --scrolltext\
        "The default names are: \n
        POD_NETWORK = snipeit1NET \n
        NETWORK_SUBNET = 10.0.6.254/24 \n
        NETWORK_GATEWAY = 10.0.6.254 \n
        NETWORK_DNS = 9.9.9.9 \n
        PODMAN_POD = snipeit1POD \n
        DATABASE_CONTAINER = snipeit1_mariadb \n
        SNIPE-IT_Container = snipeit1_snipeit \n
        \n
        Would you like to alter any of these parameters?" 20 80

    # MODIFY VARIABLES YES

        if [ $? -eq 0 ]; then
            LOOP="START"
            while [ "$LOOP" = "START" ]; do
            MENU=$(whiptail --title "Modify Defaults" --menu "" 16 80 8 \
            "PODMAN_NETWORK" "$NETWORK" \
            "NETWORK_SUBNET" "$SUBNET" \
            "NETWORK_GATEWAY" "$GATEWAY" \
            "NETWORK_DNS" "$DNS" \
            "PODMAN_POD" "$PODNAME" \
            "DATABASE_CONTAINER" "$DB_CONTAINER" \
            "SNIPE-IT_CONTAINER" "$SNIPE_CONTAINER" \
            "DONE" "" 3>&1 1>&2 2>&3)
                # MODIFY - PODMAN NETWORK NAME
                if [ "$MENU" = "PODMAN_NETWORK" ]; then
                NETWORK=$(whiptail --title "MODIFY NETWORK NAME" --inputbox " Enter your desired Podman Network Name: \n Default is 'snipeit1NET'" 20 80 3>&1 1>&2 2>&3)
                fi
                # MODIFY - NETWORK SUBNET
                if [ "$MENU" = "NETWORK_SUBNET" ]; then
                SUBNET=$(whiptail --title "MODIFY NETWORK SUBNET" --inputbox " Enter your desired Network subnet: \n Default is '10.0.6.254/24'" 20 80 3>&1 1>&2 2>&3)
                fi
                # MODIFY - NETWORK GATEWAY
                if [ "$MENU" = "NETWORK_GATEWAY" ]; then
                GATEWAY=$(whiptail --title "MODIFY NETWORK GATEWAY" --inputbox " Enter your desired Network Gateway: \n Default is '10.0.6.254'" 20 80 3>&1 1>&2 2>&3)
                fi
                # MODIFY - NETWORK DNS
                if [ "$MENU" = "NETWORK_DNS" ]; then
                DNS=$(whiptail --title "MODIFY NETWORK DNS" --inputbox " Enter your desired Network DNS: \n Default is '9.9.9.9'" 20 80 3>&1 1>&2 2>&3)
                fi
                # MODIFY - PODMAN POD NAME
                if [ "$MENU" = "PODMAN_POD" ]; then
                PODNAME=$(whiptail --title "MODIFY PODMAN POD NAME" --inputbox " Enter your desired Podman Pod Name: \n Default is 'snipeit1POD'" 20 80 3>&1 1>&2 2>&3)
                fi
                # MODIFY - DATABASE CONTAINER NAME
                if [ "$MENU" = "DATABASE_CONTAINER" ]; then
                DB_CONTAINER=$(whiptail --title "MODIFY DATABASE CONTAINER NAME" --inputbox " Enter your desired name for the Database Container \n Default is 'snipeit1_mariadb'" 20 80 3>&1 1>&2 2>&3)
                fi
                # MODIFY - SNIPE-IT CONTAINER NAME
                if [ "$MENU" = "SNIPE-IT_CONTAINER" ]; then
                SNIPE_CONTAINER=$(whiptail --title "MODIFY SNIPE-IT CONTAINER NAME" --inputbox " Enter your desired name for the Snipe-IT Container \n Default is 'snipeit1_snipeit'" 20 80 3>&1 1>&2 2>&3)
                fi
                # END LOOP
                if [ "$MENU" = "DONE" ]; then
                LOOP="STOP"
                fi
            done
        fi

### SET USERNAMES AND PASSWORDS

    # SET MYSQL_ROOT_PASSWORD
    MYSQL_ROOT_PASSWORD=$(whiptail --title "SET MYSQL ROOT PASSWORD" --inputbox "Enter a Strong Password For the MYSQL ROOT USER" 20 80 3>&1 1>&2 2>&3 )

    # SET MYSQL_USER
    MYSQL_USER=$(whiptail --title "SET MYSQL STANDARD USER NAME" --inputbox "Enter a Username for the non-root user of MYSQL" 20 80 3>&1 1>&2 2>&3 )

    # SET MYSQL_PASSWORD
    MYSQL_PASSWORD=$(whiptail --title "SET MYSQL STANDARD USER PASSWORD" --inputbox "Enter a Strong Password For the MYSQL Standared User" 20 80 3>&1 1>&2 2>&3 )


### MAKE INSTALL DIRECTORIES

    if [[ "$INSTALL_DIRECTORY" == "/var/ob" ]]
        then
        mkdir -p $INSTALL_DIRECTORY/$PODNAME/mariadb/config
        mkdir -p $INSTALL_DIRECTORY/$PODNAME/snipeit/config
        else
        mkdir -p $INSTALL_DIRECTORY/$PODNAME/mariadb/config
        mkdir -p $INSTALL_DIRECTORY/$PODNAME/snipeit/config
    fi

### CREATE PODMAN NEWORK

    podman network create \
        --subnet=$SUBNET \
        --gateway=$GATEWAY \
        --dns=$DNS \
        $NETWORK

### CREATE PODMAN POD \
    podman pod create \
        --network=$NETWORK \
        -p 8080:80 \
        $PODNAME

### CREATE CONTAINERS
    
    # MARIADB
        sudo podman run -d \
            --name=$DB_CONTAINER \
            --pod=$PODNAME \
            -e TZ=Etc/UTC \
            -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
            -e MYSQL_DATABASE=$SNIPE_CONTAINER \
            -e MYSQL_USER=$MYSQL_USER \
            -e MYSQL_PASSWORD=$MYSQL_PASSWORD \
            -v $INSTALL_DIRECTORY/$PODNAME/mariadb/config:/config \
            --restart unless-stopped \
            docker.io/linuxserver/mariadb:latest

    # SNIPE-IT
        sudo podman run -d \
            --name=$SNIPE_CONTAINER \
            --pod=$PODNAME \
            -e TZ=Etc/UTC \
            -e MYSQL_PORT_3306_TCP_ADDR=$DB_CONTAINER \
            -e MYSQL_PORT_3306_TCP_PORT=3306 \
            -e MYSQL_DATABASE=$SNIPE_CONTAINER \
            -e MYSQL_USER=$MYSQL_USER \
            -e MYSQL_PASSWORD=$MYSQL_PASSWORD \
            -e APP_URL="_/" \
            -v $INSTALL_DIRECTORY/$PODNAME/snipeit/config:/config \
            --restart unless-stopped \
            docker.io/linuxserver/snipe-it:latest

    # MODIFY DEFAULT.CONF FILE

        # SLEEP FOR NGINX TO RUN
        sleep 10

        # REMOVE 'server_name' for responce to all web requests
        sed -i '/server_name/d' $INSTALL_DIRECTORY/$PODNAME/snipeit/config/nginx/site-confs/default.conf
    
        # RESTART CONTAINER TO APPLY CHANGES
        podman restart $SNIPE_CONTAINER 


