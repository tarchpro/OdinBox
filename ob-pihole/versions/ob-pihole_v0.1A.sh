#!/bin/bash

### SET USER FOR INSTALL
    USERNAME=$(logname)

### SET DEBUG
    set -x

### INITIAL SETUP NOTICE:
    echo " PLEASE WAIT WHILE THE SYSTEM IS SETUP FOR INSTALLATION AND PACKAGES ARE CHECKED FOR THE TERMIANL USER INTERFACE"
    echo " PLEASE WAIT WHILE THE SYSTEM IS SETUP FOR INSTALLATION AND PACKAGES ARE CHECKED FOR THE TERMIANL USER INTERFACE"
    echo " PLEASE WAIT WHILE THE SYSTEM IS SETUP FOR INSTALLATION AND PACKAGES ARE CHECKED FOR THE TERMIANL USER INTERFACE"

### SET BACKTITLE TO PREVENT SCREEN BLACKING
    bbb=$(printf -- "--backtitle "INSTALL PIHOLE"")

### SET $WHIPTAIL_YN

    if rpm -q newt &>/dev/null; then
    WHIPTAIL_YN="Yes"
    else
    WHIPTAIL_YN="No"
    fi

### Install Whiptail if $WHIPTAIL_YN="No"

    if [[ $WHIPTAIL_YN == "No" ]]; then
        dnf install newt -y
    fi


### WHIPTAIL SIZE VARIABLE
    WHIPSIZE="20 80"

### OPENING USER STATEMENT

whiptail $bbb --title "WELCOME MESSAGE" \
--scrolltext --msgbox "THIS SCRIPT REQUIRES THE FOLLOWING:

1. Script must be run as root to allow for modifying network port and firewall bindings
2. Script cannot be run inside of cockpit, the system will install podman and cockpit-podman packages which will restart cockpit.
3. An IPv4 Network, this installation is not validated for IPv6

----------------------------

THE SCRIPT WILL PERFORM SOME OF THE FOLLOWING ACTIONS, FOR MORE DETAILS READ THE SCRIPT.

1. Validate the and/or correct the system timezone
2. Validate/Install Podman
3. Validate/Install Cockpit
4. Validate/Install cockpit-podman

----------------------------

THE SCRIPT IS VALIDATED FOR THE FOLLOWING OPERATING SYSTEMS ONLY.

- Fedora 37 x86" 20 80

### EULA

    while true; do
    if whiptail $bbb --title "WARNING - EULA" --yesno "I HAVE READ AND UNDERSTAND THAT I RUN THIS SCRIP ON MY OWN SYSTEM OR A SYSTEM THAT I HAVE PERMISSION TO OPERATE IN THIS FUNCTION. I UNDERSTAND WHAT THIS SCRIPT WILL DO TO MY SYSTEM AND HOLD ALL OTHERS BESIDES MYSELF TO BE FAULTLESS. \n \nIF YOU ACCEPT THESE TERMS, SELECT CONTINUE." $WHIPSIZE --yes-button "CONTINUE" --no-button "EXIT" 3>&1 1>&2 2>&3; then
            break
        else
        exit 1
    fi
    done

### Manditory Variables | $TIMEZONE $REVERSEPROXY_YN $DHCP_YN $USERPASSWORD
    # SET MANDITORY DEFAULTS
    whiptail $bbb --title "MANDATORY VARIABLES" \
    --msgbox "The following variables must be set to complete install. You will have the option to set non-manditory variables later:

    - Time Zone
    - External Proxy Server
    - DHCP Service
    - User Password" $WHIPSIZE

        # Time Zone - $TIMEZONE
            # Pull the system timezone
            TIMEZONE=$(timedatectl | grep "Time zone" | awk '{print $3}')

            if whiptail $bbb --title "TIMEZONE" --yesno "The current system timezone is $TIMEZONE. Is this correct?" $WHIPSIZE --yes-button "YES" --no-button "NO"; then
                # Do Nothing
                echo " "
            else
                # Ask for the correct timezone
                TIMEZONE=$(whiptail $bbb --title "TIMEZONE" --inputbox "Please enter the correct time zone:" $WHIPSIZE "" 3>&1 1>&2 2>&3)
            fi

        # EXTERNAL PROXY SERVER - $REVERSEPROXY_YN
            # ASK ABOUT EXTERNAL PROXY - SET $REVERSEPROXY_YN
            if whiptail $bbb --title "EXTERNAL REVERSE PROXY" --yesno "Will you use an reverse proxy engine to forward web requests to this pod/container? \n \n If yes, a different port binding will be set to increase machine usability. \n \n (DEFAULT NO)" --yes-button "YES" --no-button "No"; then
                # IF YES - Set $REVERSEPROXY_YN
                REVERSEPROXY_YN="yes"
            else
                # IF NO - Set $REVERSEPROXY_YN
                REVERSEPROXY_YN="no"
            fi

        # DHCP SERVICE - $DHCP_yn
            # ASK ABOUT DHCP SERVICE - $DHCP_YN
            if whiptail $bbb --title "DHCP SERVER" --yesno "Will you use the PiHole DHCP service? \n \n (DEFAULT NO)" --yes-button "YES" --no-button "NO"; then
                # IF YES - SET $DHCP_YN
                DHCP_YN="yes"
            else
                # IF NO - SET $DHCP_YN
                DHCP_YN="no"
            fi
        
        # USER PASSWORD
            # Set PASSWORD_MEETS==FALSE
            PASSWORD_MEETS=FALSE

            # RUN LOOP UNTIL PASSWORD MEETS = TRUE - Password must meet safety requirements
            while [[ "$PASSWORD_MEETS" == FALSE ]]; do
                USERPASSWORD=$(whiptail $bbb --title "USER PASSWORD" --passwordbox "Enter a reasonably safe password for the PiHole web interface, the password must have the following \n - atleast one UPPERCASE letter \n - ATLEAST ONE lowercase LETTER \n - Atleast one special character *#&@ \n - Atleast one numberal 1-9 \n - Atleast 8 characters " $WHIPSIZE 3>&1 1>&2 2>&3)
                
                if [[ ${#USERPASSWORD} -lt 8 ]] || \
                        ! [[ $USERPASSWORD =~ [A-Z] ]] || \
                        ! [[ $USERPASSWORD =~ [a-z] ]] || \
                        ! [[ $USERPASSWORD =~ [0-9] ]] || \
                        ! [[ $USERPASSWORD =~ [^a-zA-Z0-9] ]]; then
                    whiptail $bbb --title "INVALID PASSWORD" --msgbox "The password you entered does not meet the minimum safety requirements. Please try again." $WHIPSIZE
                else
                    PASSWORD_MEETS=true
                fi
            done

### Optional Variables
    # Set Optional Default Variables
        CONTAINERNAME="pihole"
        PODNAME="piholePOD"
        LANIP="not-set"
        UPSTREAMDNS="9.9.9.9,8.8.8.8,8.8.4.4"
        DNSSEC_TF="false"
        DNS_BOGUS_PRIV_TF="false"
        DNS_FQDN_REQUIRED_TF="true"
        REV_SERVER_TF="false"
        REV_SERVER_DOMAIN="not-set"
        REV_SERVER_TARGET="not-set"
        REV_SERVER_CIDR="not-set"
        DHCP_ACTIVE_TF="false"
        DHCP_START="not-set"
        DHCP_END="not-set"
        DHCP_ROUTER="not-set"
        DHCP_LEASETIME="24"
        PIHOLE_DOMAIN="lan"
        DHCP_IPV6_TF="false"
        DHCP_RAPID_COMMIT_TF="false"
        VIRTUAL_HOST=$(hostname)
        IPV6_TF="true"
        TEMPERATUREUNIT="c"
        WEBUIBOXEDLAYOUT="boxed"
        QUERY_LOGGING_TF="true"
        WEBTHEME="default-light"

        # User Option - Do you want to Edit
            if whiptail $bbb --title "OPTIONAL VARIABLES" --yesno \
                 " ---- Would you like to modify any of the optional variables? ---- \n \n ================================================================= \n |  CONTAINER NAME     |  POD NAME         |  FTLCONF_LOCAL_IPV4  | \n |  PIHOLE_DNS_	        |  DNSSEC           |  DNS_BOGUS_PRIV      | \n |  DNS_FQDN_REQUIRED  |  REV_SERVER       |  REV_SERVER_DOMAIN   | \n |  REV_SERVER_TARGET  |  REV_SERVER_CIDR  |  DHCP_ACTIVE         | \n |  DHCP_START         |  DHCP_END         |  DHCP_ROUTER         | \n |  DHCP_LEASETIME     |  PIHOLE_DOMAIN    |  DHCP_IPv6           | \n |  DHCP_rapid_commit  |  VIRTUAL_HOST     |  IPv6                | \n |  TEMPERATUREUNIT    |  WEBUIBOXEDLAYOUT |  QUERY_LOGGING       | \n |  WEBTHEME           |                   |                      | \n ================================================================= " $WHIPSIZE 3>&1 1>&2 2>&3; then
                # START LOOP
                while true; do    
                    # IF YES, OPTIONAL MAIN MENU
                    OPTIONAL_MENU_OPTION=$(whiptail $bbb --title "OPTIONAL VARIABLES" --menu "Select a variable to edit:" 32 80 26 \
                    "Container Name" "$CONTAINERNAME" \
                    "Pod Name" "$PODNAME" \
                    "FTLCONF_LOCAL_IPV4" "$LANIP" \
                    "PIHOLE_DNS_" "$UPSTREAMDNS" \
                    "DNSSEC" "$DNSSEC_TF" \
                    "DNS_BOGUS_PRIV" "$DNS_BOGUS_PRIV_TF" \
                    "DNS_FQDN_REQUIRED" "$DNS_FQDN_REQUIRED_TF" \
                    "REV_SERVER" "$REV_SERVER_TF" \
                    "REV_SERVER_DOMAIN" "$REV_SERVER_DOMAIN" \
                    "REV_SERVER_TARGET" "$REV_SERVER_TARGET" \
                    "REV_SERVER_CIDR" "$REV_SERVER_CIDR" \
                    "DHCP_ACTIVE" "$DHCP_ACTIVE_TF" \
                    "DHCP_START" "$DHCP_START" \
                    "DHCP_END" "$DHCP_END" \
                    "DHCP_ROUTER" "$DHCP_ROUTER" \
                    "DHCP_LEASETIME" "$DHCP_LEASETIME" \
                    "PIHOLE_DOMAIN" "$PIHOLE_DOMAIN" \
                    "DHCP_IPv6" "$DHCP_IPV6_TF" \
                    "DHCP_rapid_commit" "$DHCP_RAPID_COMMIT_TF" \
                    "VIRTUAL_HOST" "$VIRTUAL_HOST" \
                    "IPv6" "$IPV6_TF" \
                    "TEMPERATUREUNIT" "$TEMPERATUREUNIT" \
                    "WEBUIBOXEDLAYOUT" "$WEBUIBOXEDLAYOUT" \
                    "QUERY_LOGGING" "$QUERY_LOGGING_TF" \
                    "WEBTHEME" "$WEBTHEME" \
                    "DONE" "" 3>&1 1>&2 2>&3)
                        # IF "Container Name" - MODIFY "$CONTAINERNAME"
                            if [ "$OPTIONAL_MENU_OPTION" = "Container Name" ]; then
                            CONTAINERNAME=$(whiptail $bbb --title "CONTAINER NAME" --inputbox "Enter the desired name for the podman container:" $WHIPSIZE 3>&1 1>&2 2>&3)
                            fi
                        # IF "Pod Name" - MODIFY "$PODNAME" 
                            if [ "$OPTIONAL_MENU_OPTION" = "Pod Name" ]; then
                            PODNAME=$(whiptail $bbb --title "POD NAME" --inputbox "Enter the desired name for the podman pod:" $WHIPSIZE 3>&1 1>&2 2>&3)
                            fi
                        # IF "FTLCONF_LOCAL_IPV4" - MODIFY "$LANIP" 
                            if [ "$OPTIONAL_MENU_OPTION" = "FTLCONF_LOCAL_IPV4" ]; then
                            LANIP=$(whiptail $bbb --title "FTLCONF_LOCAL_IPV4" --inputbox " -------------------------ENTER FTLCONF_LOCAL_IPV4------------------------- \n  ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n  -------------------------------------------------------------------------- \n \n Set to your server's LAN IP, used by web block modes. Default 'unset'." $WHIPSIZE 3>&1 1>&2 2>&3)
                            fi
                        # IF "PIHOLE_DNS_" - MODIFY "$UPSTREAMDNS" 
                            if [ "$OPTIONAL_MENU_OPTION" = "PIHOLE_DNS_" ]; then
                            UPSTREAMDNS=$(whiptail $bbb --title "PIHOLE_DNS_" --inputbox " ----------------------------ENTER PIHOLE_DNS_---------------------------- \n  ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n  -------------------------------------------------------------------------- \n \n Upstream DNS server(s) for Pi-hole to forward queries to, separated by a semicolon(supports non-standard ports with #[port number]) e.g 127.0.0.1#5053;8.8.8.8;8.8.4.4(supports Docker service names and links instead of IPs) e.g upstream0;upstream1 where upstream0 and upstream1 are the service names of or links to docker services Note: The existence of this environment variable assumes this as the sole management of upstream DNS. Upstream DNS added via the web interface will be overwritten on container restart/recreation. Default, '9.9.9.9;8.8.8.8;8.8.4.4'" $WHIPSIZE 3>&1 1>&2 2>&3)
                            fi
                        # IF "DNSSEC" - MODIFY "$DNSSEC_TF" 
                            if [ "$OPTIONAL_MENU_OPTION" = "DNSSEC" ]; then
                            DNSSEC_TF=$(whiptail $bbb --title "DNSSEC" --radiolist " -------------------------------- DNSSEC --------------------------------- \n  ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n  -------------------------------------------------------------------------- \n \n Enable DNSSEC support. Default,'false'" $WHIPSIZE 2 \
                            "true" "" OFF \
                            "false" "" ON 3>&1 1>&2 2>&3)
                            fi
                        # IF "DNS_BOGUS_PRIV" - MODIFY "$DNS_BOGUS_PRIV_TF" 
                            if [ "$OPTIONAL_MENU_OPTION" = "DNS_BOGUS_PRIV" ]; then
                            DNS_BOGUS_PRIV_TF=$(whiptail $bbb --title "DNS_BOGUS_PRIV_TF" --radiolist " -------------------------------- DNS_BOGUS_PRIV --------------------------------- \n  ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n  -------------------------------------------------------------------------- \n \n Never forward reverse lookups for private ranges. Default,'true'" $WHIPSIZE 2 \
                            "true" "" ON \
                            "false" "" OFF 3>&1 1>&2 2>&3)
                            fi
                        # IF "DNS_FQDN_REQUIRED" - MODIFY "$DNS_FQDN_REQUIRED_TF" 
                            if [ "$OPTIONAL_MENU_OPTION" = "DNS_FQDN_REQUIRED" ]; then
                            DNF_FQDN_REQUIRED_TF=$(whiptail $bbb --title "DNS_FQDN_REQUIRED" --radiolist " -------------------------- DNS_FQDN_REQUIRED ---------------------------- \n  ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n  -------------------------------------------------------------------------- \n \n Never forward non-FQDNs. Default,'true'" $WHIPSIZE 2 \
                            "true" "" ON \
                            "false" "" OFF 3>&1 1>&2 2>&3)
                            fi
                        # IF "REV_SERVER" - MODIFY "$REV_SERVER_TF" 
                            if [ "$OPTIONAL_MENU_OPTION" = "REV_SERVER" ]; then
                            REV_SERVER_TF=$(whiptail $bbb --title "REV_SERVER" --radiolist " ------------------------------ REV_SERVER ------------------------------- \n  ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n  -------------------------------------------------------------------------- \n \n Enable DNS conditional forwarding for device name resolution. Default,'false'" $WHIPSIZE 2 \
                            "true" "" OFF \
                            "false" "" ON 3>&1 1>&2 2>&3)
                                # IF "REV_SERVER_TF = true"
                                if [ "$REV_SERVER_TF" = "true" ]; then
                                    # MODIFY "$REV_SERVER_DOMAIN" 
                                    REV_SERVER_DOMAIN=$(whiptail $bbb --title "REV_SERVER_DOMAIN" --inputbox " --------------------------- REV_SERVER_DOMAIN --------------------------- \n  ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n  -------------------------------------------------------------------------- \n \n If conditional forwarding is enabled, set the domain of the local network router. Default,'unset'" $WHIPSIZE 3>&1 1>&2 2>&3)
                                    # MODIFY "$REV_SERVER_TARGET" 
                                    REV_SERVER_TARGET=$(whiptail $bbb --title "REV_SERVER_TARGET" --inputbox " --------------------------- REV_SERVER_DOMAIN --------------------------- \n  ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n  -------------------------------------------------------------------------- \n \n If conditional forwarding is enabled, set the domain of the local network router. Default,'unset'" $WHIPSIZE 3>&1 1>&2 2>&3)
                                    # MODIFY "$REV_SERVER_CIDR" 
                                    REV_SERVER_CIDR=$(whiptail $bbb --title "REV_SERVER_CIDR" --inputbox " ----------------------------- REV_SERVER_CIDR --------------------------- \n  ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n  -------------------------------------------------------------------------- \n \n If conditional forwarding is enabled, set the reverse DNS zone (e.g. 192.168.0.0/24). Default,'unset'" $WHIPSIZE 3>&1 1>&2 2>&3)
                                fi
                            fi
                        # IF "DHCP_ACTIVE" - MODIFY "$DHCP_ACTIVE_TF" 
                            if [ "$OPTIONAL_MENU_OPTION" = "DHCP_ACTIVE" ]; then
                            DHCP_ACTIVE_TF=$(whiptail $bbb --title "DHCP_ACTIVE" --radiolist " ------------------------------- DHCP_ACTIVE ----------------------------- \n  ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n  -------------------------------------------------------------------------- \n \n Enable DHCP server. Static DHCP leases can be configured with a custom /etc/dnsmasq.d/04-pihole-static-dhcp.conf. Default,'false'" $WHIPSIZE 2 \
                            "true" "" NO \
                            "false" "" YES 3>&1 1>&2 2>&3)
                                # IF "DHCP_ACTIVE = true"
                                if [ "$DHCP_ACTIVE_TF" = "true" ]; then
                                    # MODIFY "$DHCP_START" 
                                    DHCP_START=$(whiptail $bbb --title "DHCP_START" --inputbox " -------------------------------- DHCP_START ----------------------------- \n  ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n  -------------------------------------------------------------------------- \n \n Start of the range of IP addresses to hand out by the DHCP server (mandatory if DHCP server is enabled). Default,'unset'" $WHIPSIZE 3>&1 1>&2 2>&3)                               
                                    # MODIFY "$DHCP_END" 
                                    DHCP_END=$(whiptail $bbb --title "DHCP_END" --inputbox " --------------------------------- DHCP_END ------------------------------ \n  ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n  -------------------------------------------------------------------------- \n \n End of the range of IP addresses to hand out by the DHCP server (mandatory if DHCP server is enabled). Default,'unset'" $WHIPSIZE 3>&1 1>&2 2>&3)
                                    # MODIFY "$DHCP_ROUTER" 
                                    DHCP_ROUTER=$(whiptail $bbb --title "DHCP_ROUTER" --inputbox " -------------------------------- DHCP_ROUTER ---------------------------- \n  ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n  -------------------------------------------------------------------------- \n \n Router (gateway) IP address sent by the DHCP server (mandatory if DHCP server is enabled). Default,'unset'" $WHIPSIZE 3>&1 1>&2 2>&3)
                                    # MODIFY "$DHCP_LEASETIME" 
                                    DHCP_LEASETIME=$(whiptail $bbb --title "DHCP_LEASETIME" --inputbox " ------------------------------ DHCP_LEASETIME --------------------------- \n  ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n  -------------------------------------------------------------------------- \n \n DHCP lease time in hours. Default,'24'" $WHIPSIZE 3>&1 1>&2 2>&3)
                                    # MODIFY "PIHOLE_DOMAIN"
                                    PIHOLE_DOMAIN=$(whiptail $bbb --title "PIHOLE_DOMAIN" --inputbox " ------------------------------ PIHOLE_DOMAIN ---------------------------- \n  ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n  -------------------------------------------------------------------------- \n \n Domain name sent by the DHCP server. Default,'lan'" $WHIPSIZE 3>&1 1>&2 2>&3)
                                fi
                            fi
                        # IF "DHCP_IPv6" - MODIFY "$DHCP_IPV6_TF" 
                            if [ "$OPTIONAL_MENU_OPTION" = "DHCP_IPv6" ]; then
                            DHCP_IPV6_TF=$(whiptail $bbb --title "DHCP_IPv6" --radiolist " -------------------------------- DHCP_IPv6 ------------------------------ \n  ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n  -------------------------------------------------------------------------- \n \n Enable DHCP server IPv6 support (SLAAC + RA). Default,'flase'" $WHIPSIZE 2 \
                            "true" "" OFF \
                            "false" "" ON 3>&1 1>&2 2>&3)    
                            fi
                        # IF "DHCP_rapid_commit" - MODIFY "$DHCP_RAPID_COMMIT_TF" 
                            if [ "$OPTIONAL_MENU_OPTION" = "DHCP_rapid_commit" ]; then
                            DHCP_RAPPID_COMMIT_TF=$(whiptail $bbb --title "DHCP_rapid_commit" --radiolist " ---------------------------- DHCP_rapid_commit -------------------------- \n  ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n  -------------------------------------------------------------------------- \n \n Enable DHCPv4 rapid commit (fast address assignment). Default,'flase'" $WHIPSIZE 2 \
                            "true" "" OFF \
                            "false" "" ON 3>&1 1>&2 2>&3) 
                            fi
                        # IF "VIRTUAL_HOST" - MODIFY "$VIRTUAL_HOST" 
                            if [ "$OPTIONAL_MENU_OPTION" = "VIRTUAL_HOST" ]; then
                            VIRTUAL_HOST=$(whiptail $bbb --title "VIRTUAL_HOST" --inputbox " ------------------------------- VIRTUAL_HOST ---------------------------- \n  ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n  -------------------------------------------------------------------------- \n \n What your web server 'virtual host' is, accessing admin through this Hostname/IP allows you to make changes to the whitelist / blacklists in addition to the default 'http://pi.hole/admin/' address. Default,'${HOSTNAME}'" $WHIPSIZE 3>&1 1>&2 2>&3)
                            fi
                        # IF "IPv6" - MODIFY "$IPV6_TF" 
                            if [ "$OPTIONAL_MENU_OPTION" = "IPv6" ]; then
                            IPV6_TF=$(whiptail $bbb --title "IPv6" --radiolist " ---------------------------------- IPv6 --------------------------------- \n  ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n  -------------------------------------------------------------------------- \n \n For unraid compatibility, strips out all the IPv6 configuration from DNS/Web services when false. Default,'true'" $WHIPSIZE 2 \
                            "true" "" ON \
                            "false" "" OFF 3>&1 1>&2 2>&3)    
                            fi
                        # IF "TEMPERATUREUNIT" - MODIFY "$TEMPERATUREUNIT" 
                            if [ "$OPTIONAL_MENU_OPTION" = "TEMPERATUREUNIT" ]; then
                            TEMPERATUREUNIT=$(whiptail $bbb --title "TEMPERATUREUNIT" --radiolist " ------------------------------- RADIOLIST ------------------------------- \n  ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n -------------------------------------------------------------------------- \n \n Set preferred temperature unit to c: Celsius, k: Kelvin, or f Fahrenheit units. Note: This only affects chronometer and PADD. The web interface's temperature unit is set on a per-browser basis in the UI settings. Default,'c'" $WHIPSIZE 3 \
                            "f" "" OFF \
                            "c" "" ON \
                            "k" "" OFF 3>&1 1>&2 2>&3)
                            fi
                        # IF "WEBUIBOXEDLAYOUT" - MODIFY "$WEBUIBOXEDLAYOUT" 
                            if [ "$OPTIONAL_MENU_OPTION" = "WEBUIBOXEDLAYOUT" ]; then
                            WEBUIBOXEDLAYOUT=$(whiptail $bbb --title "WEBUIBOXEDLAYOUT" --radiolist " ------------------------------- WEBUILAYOUT ------------------------------- \n  ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n  -------------------------------------------------------------------------- \n \n Use boxed layout (helpful when working on large screens). Default 'boxed'" $WHIPSIZE 2 \
                            "boxed" "" ON \
                            "traditional" "" OFF 3>&1 1>&2 2>&3)
                            fi
                        # IF "QUERY_LOGGING" - MODIFY "$QUERY_LOGGING_TF" 
                            if [ "$OPTIONAL_MENU_OPTION" = "QUERY_LOGGING" ]; then
                            QUERY_LOGGING_TF=$(whiptail $bbb --title "QUERY_LOGGING" --radiolist " ----------------------------- QUERY_LOGGING ----------------------------- \n  ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n  -------------------------------------------------------------------------- \n \n Use boxed layout (helpful when working on large screens). Default 'true'" $WHIPSIZE 2 \
                            "true" "" ON \
                            "false" "" OFF 3>&1 1>&2 2>&3)
                            fi
                        # IF "WEBTHEME" - MODIFY "$WEBTHEME" 
                            if [ "$OPTIONAL_MENU_OPTION" = "WEBTHEME" ]; then
                            WEBTHEME=$(whiptail $bbb --title "WEBTHEME" --radiolist " -------------------------------- WEBTHEME ------------------------------- \n  ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n  -------------------------------------------------------------------------- \n \n User interface theme to use. Default 'default-light'" $WHIPSIZE 5 \
                            "default-dark" "" NO \
                            "default-darker" "" NO \
                            "default-light" "" YES \
                            "default-auto" "" NO \
                            "lcars" "" NO 3>&1 1>&2 2>&3)
                            fi
                        # IF "DONE" - END LOOP 
                            if [ "$OPTIONAL_MENU_OPTION" = "DONE" ]; then
                                break
                            fi
                        # If "CANCEL" - Exit Script
                            if [ "$OPTIONAL_MENU_OPTION" = "" ]; then
                                exit 1
                            fi
                done
            fi

### Advanced Variables
    # Set Advanced Default Variables
        INTERFACE="not-set"
        DNSMASQ_LISTENING="not-set"
        WEB_PORT="not-set"
        WEB_BIND_ADDR="not-set"
        SKIPGRAVITYONBOOT="not-set"
        CORS_HOSTS="not-set"
        CUSTOM_CACHE_SIZE="1000"
        FTL_CMD="no-daemon"
        PIHOLE_VERSION="latest"

        # User Option - Do you want to Edit
            if whiptail $bbb --title "ADVANCED VARIABLES" --yesno "Would you like to modify any of the advanced variables? \n \n ========================================================== \n | INTERFACE           |  DNSMASQ_LISTENING |  WEB_PORT   | \n |  WEB_BIND_ADDR      |  SKIPGRAVITYONBOOT |  CORS_HOSTS | \n |  CUSTOM_CACHE_SIZE  |  FTL_CMD           |  FTLCONF_   | \n ========================================================== " $WHIPSIZE 3>&1 1>&2 2>&3; then
                # START LOOP
                while true; do    
                    # IF YES, ADVANCED MAIN MENU
                    ADVANCED_MENU_OPTION=$(whiptail $bbb --title "ADVANCED VARIABLES" --menu "Select a variable to edit:" 20 80 10 \
                    "INTERFACE" "$INTERFACE" \
                    "DNSMASQ_LISTENING" "$DNSMASQ_LISTENING" \
                    "WEB_PORT" "$WEB_PORT" \
                    "WEB_BIND_ADDR" "$WEB_BIND_ADDR" \
                    "SKIPGRAVITYONBOOT" "$SKIPGRAVITYONBOOT" \
                    "CORS_HOSTS" "$CORS_HOSTS" \
                    "CUSTOM_CACHE_SIZE" "$CUSTOM_CACHE_SIZE" \
                    "FTL_CMD" "$FTL_CMD" \
                    "PIHOLE_VERSION" "$PIHOLE_VERSION" \
                    "DONE" "" 3>&1 1>&2 2>&3) 
                        # IF "INTERFACE" - MODIFY $INTERFACE
                            if [ "$ADVANCED_MENU_OPTION" = "INTERFACE" ]; then
                            INTERFACE=$(whiptail $bbb --title "INTERFACE" --inputbox " -------------------------------------------------------------------------- \n ---------------------ENTER THE DESIRED INTERFACE NAME--------------------- \n ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n -------------------------------------------------------------------------- \n \nThe default works fine with our basic example docker run commands. If you're trying to use DHCP with --net host mode then you may have to customize this or DNSMASQ_LISTENING." $WHIPSIZE 3>&1 1>&2 2>&3)
                            fi
                        # IF "DNSMASQ_LISTENING" - MODIFY $DNSMASQ_LISTENING
                            if [ "$ADVANCED_MENU_OPTION" = "DNSMASQ_LISTENING" ]; then
                            DNSMASQ_LISTENING=$(whiptail $bbb --title "DNSMASQ_LISTENING" --radiolist " -------------------SELECT THE NETWORK LISTENING VARIABLE------------------ \n ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n \n" 20 88 3 "local" "local listens on all local subnets" OFF "all" "all permits listening on internet origin subnets in addition to local" OFF "single" "single listens only on the interface specified" OFF --nocancel 3>&1 1>&2 2>&3)
                                # IF "DNSMASQ_LISTENING = single" - MODIFY $DNSMASQ_LISTENING FOR USER VARIABLE
                                if [ "$DNSMASQ_LISTENING" = "single" ]; then
                                DNSMASQ_LISTENING=$(whiptail $bbb --title "DNSMASQ_LISTENING | SET single" --inputbox "ENTER THE INTERFACE YOU WOULD LIKE 'DNSMASQ' TO LISTEN ON" $WHIPSIZE 3>&1 1>&2 2>&3)
                                fi
                            fi
                        # IF "WEB_PORT" - MODIFY $WEB_PORT
                            if [ "$ADVANCED_MENU_OPTION" = "WEB_PORT" ]; then
                            WEB_PORT=$(whiptail $bbb --title "WEB_PORT" --inputbox " ------------------SELECT THE WEB PORT LISTENING VARIABLE----------------- \n ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n -------------------------------------------------------------------------- \nThis will break the 'webpage blocked' functionality of Pi-hole however it may help advanced setups like those running synology or --net=host docker argument. This guide explains how to restore webpage blocked functionality using a linux router DNAT rule: https://discourse.pi-hole.net/t/alternative-synology-installation-method/5454?u=diginc" 20 90 3>&1 1>&2 2>&3)
                            fi
                        # IF "WEB_BIND_ADDR" - MODIFY $WEB_BIND_ADDR
                            if [ "$ADVANCED_MENU_OPTION" = "WEB_BIND_ADDR" ]; then
                            WEB_BIND_ADDR=$(whiptail $bbb --title "WEB_BIND_ADDR" --inputbox " ------------------------ENTER THE WEB BIND ADDR IP----------------------- \n ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n -------------------------------------------------------------------------- \nLighttpd's bind address. If left unset lighttpd will bind to every interface, except when running in host networking mode where it will use FTLCONF_LOCAL_IPV4 instead." $WHIPSIZE 3>&1 1>&2 2>&3)
                            fi
                        # IF "SKIPGRAVITYONBOOT" - MODIFY $SKIPGRAVITYONBOOT
                            if [ "$ADVANCED_MENU_OPTION" = "SKIPGRAVITYONBOOT" ]; then
                            SKIPGRAVITYONBOOT=$(whiptail $bbb --title "SKIP GRAVITY ON BOOT" --radiolist " --------------------SELECT 1 TO SKIP GRAVITY ON BOOT--------------------- \n ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n -------------------------------------------------------------------------- \n \nUse this option to skip updating the Gravity Database when booting up the container. By default this environment variable is not set so the Gravity Database will be updated when the container starts up. Setting this environment variable to 1 (or anything) will cause the Gravity Database to not be updated when container starts up." $WHIPSIZE 2 "no" "unset" ON "1" "SKIP On BOOT" OFF 3>&1 1>&2 2>&3)
                            fi
                        # IF "CORS_HOSTS" - MODIFY $CORS_HOSTS
                            if [ "$ADVANCED_MENU_OPTION" = "CORS_HOSTS" ]; then
                            CORS_HOSTS=$(whiptail $bbb --title "CORS_HOSTS" --inputbox " ----------------------ENTER DOMAINS FOR CORS HOSTS----------------------- \n ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n -------------------------------------------------------------------------- \n \nList of domains/subdomains on which CORS is allowed. Wildcards are not supported. Eg: CORS_HOSTS: domain.com,home.domain.com,www.domain.com." $WHIPSIZE 3>&1 1>&2 2>&3)
                            fi
                        # IF "CUSTOM_CACHE_SIZE" - MODIFY $CUSTOM_CACHE_SIZE
                            if [ "$ADVANCED_MENU_OPTION" = "CUSTOM_CACHE_SIZE" ]; then
                            CUSTOM_CACHE_SIZE=$(whiptail $bbb --title "CUSTOM_CACHE_SIZE" --inputbox " ------------------------ENTER CUSTOM CACHE SIZE------------------------- \n ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n -------------------------------------------------------------------------- \n \nSet the cache size for dnsmasq. Useful for increasing the default cache size or to set it to 0. Note that when DNSSEC is 'true', then this setting is ignored. Default is 10000." $WHIPSIZE 3>&1 1>&2 2>&3)
                            fi
                        # IF "FTL_CMD" - MODIFY $FTL_CMD
                            if [ "$ADVANCED_MENU_OPTION" = "FTL_CMD" ]; then
                            FTL_CMD=$(whiptail $bbb --title "FTL_CMD" --inputbox " -----------------------ENTER CUSTOM DNSMASQ START------------------------ \n ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n -------------------------------------------------------------------------- \n \nCustomize the options with which dnsmasq gets started. e.g. no-daemon -- --dns-forward-max 300 to increase max. number of concurrent dns queries on high load setups. Default 'no-daemon'" $WHIPSIZE 3>&1 1>&2 2>&3)
                            fi
                        # IF "PIHOLE_VERSION" - MODIFY $PIHOLE_VERSION  
                            if [ "$ADVANCED_MENU_OPTION" = "PIHOLE_VERSION" ]; then
                            PIHOLE_VERSION=$(whiptail $bbb --title "PIHOLE_VERSION" --inputbox " -----------------------ENTER CUSTOM PIHOLE VERSION----------------------- \n ------THE FOLLOWING DESCRIPTION OF THE VARIABLE IS PROVIDED BY PIHOLE----- \n -------------------------------------------------------------------------- \n \nCustomize the release version for installation. This is used at the end of the command 'docker.io/pihole/pihole:'PIHOLE_VERSION''. Default 'latest'." $WHIPSIZE 3>&1 1>&2 2>&3)
                            fi
                        # IF "DONE" - END LOOP
                            if [ "$ADVANCED_MENU_OPTION" = "DONE" ]; then
                                break
                            fi
                        # IF "CANCEL" - EXIT SCRIPT
                            if [ "$ADVANCED_MENU_OPTION" = "" ]; then
                                exit 1
                            fi
                done
        fi
    
### Setup System Configuration
{
    # Check Fedora Version | end script if version not supported
        fedoraversion=$(cat /etc/fedora-release)
        if ! [[ $fedoraversion =~ "Fedora release 37 (Thirty Seven)" ]]; then
            if whiptail $bbb--title "UNSUPPORTED VERSION" --msgbox "Your version of Fedora $fedoraversion is unsupported by this script." 20 80 ; then
                exit 1
            fi
        fi

    # Install/Enable bind-utils | cockpit | podman | cockpit-podman
        dnf install bind-utils cockpit podman cockpit-podman -y
        systemctl enable bind-utils cockpit podman cockpit-podman
        systemctl start bind-utils cockpit podman cockpit-podman

    # Open Firewall Ports
        # 53/TCP/UDP - DNS
            firewall-cmd --add-port=53/tcp
            firewall-cmd --add-port=53/tcp --permanent
            firewall-cmd --add-port=53/udp
            firewall-cmd --add-port=53/udp --permanent

        # 80/TCP or 8080/TCP - HTTP
            if [[ $REVERSEPROXY_YN == "yes" ]]; then
            firewall-cmd --add-port=8080/tcp
            firewall-cmd --add-port=8080/tcp --permanent
            fi

            if [[ $REVERSEPROXY_YN == "no" ]]; then
            firewall-cmd --add-port=80/tcp
            firewall-cmd --add-port=80/tcp --permanent
            fi
        
        # 67/UDP - If Using DHCP
            if [[ $DHCP_ACTIVE_YN == "yes" ]]; then
            firewall-cmd --add-port=80/udp
            firewall-cmd --add-port=80/udp --permanent
            fi

    # Restart Firewall
        systemctl restart firewalld
    
    # Create Container Mount Points
        mkdir -p $hostmounthome/pihole_pihole
        mkdir -p $hostmounthome/pihole_dnsmasq
    
    # Modify the systemd DNS settings to free port 53 from systemd && symlink

        # Disable systemd Stub Resolver
        sed -r -i.orig 's/#?DNSStubListener=yes/DNSStubListener=no/g' /etc/systemd/resolved.conf

        # Change the /etc/resolv.conf symlink to point to /run/systemd/resolve/resolv.conf
        sudo sh -c 'rm /etc/resolv.conf && ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf'

        # Restart systemd-resolved
        sudo systemctl restart systemd-resolved

    # CREATE POD
    sudo -u $USERNAME podman pod create \
    --name $PODNAME \
    $(if [[ "$DHCP_YN" == "yes" ]]; then echo "-p 67:67"; fi)\
    $(if [[ "$REVERSEPROXY_YN" == "yes" ]]; then echo "-p 8080:80"; fi)\
    $(if [[ "$REVERSEPROXY_YN" == "no" ]]; then echo "-p 80:80"; fi)\
    $(if [[ "$REVERSEPROXY_YN" == "no" ]]; then echo "-p 443:443"; fi)\
    -p 53:53/tcp \
    -p 53:53/udp 
        
### Install Script
    sudo -u $USERNAME podman run -d \
        --name $CONTAINERNAME \
        --pod=$PODNAME \
        -e TZ=$TIMEZONE\
        -e WEBPASSWORD=$USERPASSWORD\
        -e FTLCONF_LOCAL_IPV4=$LANIP\
        -e PIHOLE_DNS=$UPSTREAMDNS\
            $(if [[ "$DNSSEC_TF" == "true" ]]; then echo "-e DNSSEC=$DNSSEC_TF"; fi)\
            $(if [[ "$DNS_BOGUS_PRIV_TF" == "false" ]]; then echo "-e DNS_BOGUS_PRIV=$DNS_BOGUS_PRIV_TF"; fi)\
            $(if [[ "$DNS_FQDN_REQUIRED_TF" == "false" ]]; then echo "-e DNS_FQDN_REQUIRED=$DNS_FQDN_REQUIRED_TF"; fi)\
            $(if [[ "$REV_SERVER_TF" == "true" ]]; then echo "-p REV_SERVER=true"; fi)\
            $(if [[ "$REV_SERVER_TF" == "true" ]]; then echo "-e REV_SERVER_DOMAIN=$REV_SERVER_DOMAIN"; fi)\
            $(if [[ "$REV_SERVER_TF" == "true" ]]; then echo "-e REV_SERVER_TARGET=$REV_SERVER_TARGET"; fi)\
            $(if [[ "$REV_SERVER_TF" == "true" ]]; then echo "-e REV_SERVER_CIDR=$REV_SERVER_CIDR"; fi)\
            $(if [[ "$DHCP_ACTIVE_TF" == "true" ]]; then echo "-e DHCP_ACTIVE=$DHCP_ACTIVE_TF"; fi)\
            $(if [[ "$DHCP_ACTIVE_TF" == "true" ]]; then echo "-e DHCP_START=$DHCP_START"; fi)\
            $(if [[ "$DHCP_ACTIVE_TF" == "true" ]]; then echo "-e DHCP_END=$DHCP_END"; fi)\
            $(if [[ "$DHCP_ROUTER_TF" == "true" ]]; then echo "-e DHCP_ROUTER=$DHCP_ROUTER"; fi)\
            $(if [[ "$DHCP_LEASETIME" != "24" ]]; then echo "-e DHCP_LEASETIME=$DHCP_LEASETIME"; fi)\
            $(if [[ "$PIHOLE_DOMAIN" != "lan" ]]; then echo "-e PIHOLE_DOMAIN=$PIHOLE_DOMAIN"; fi)\
            $(if [[ "$DHCP_IPV6_TF" == "true" ]]; then echo "-e DHCP_IPV6=$DHCP_IPV6_TF"; fi)\
            $(if [[ "$DHCP_RAPID_COMMIT_TF" == "true" ]]; then echo "-e DHCP_rapid_commit=$DHCP_RAPID_COMMIT_TF"; fi)\
        -e VIRTUAL_HOST=$VIRTUAL_HOST\
            $(if [[ "$IPV6_TF" == "true" ]]; then echo "-e IPv6=$IPV6_TF"; fi)\
            $(if [[ "$TEMPERATUREUNIT" != "c" ]]; then echo "-e TEMPERATUREUNIT=$TEMPERATUREUNIT"; fi)\
            $(if [[ "$WEBUIBOXEDLAYOUT" != "boxed" ]]; then echo "-e WEBUIBOXEDLAYOUT=$WEBUIBOXEDLAYOUT"; fi)\
            $(if [[ "$QUERY_LOGGING_TF" == "false" ]]; then echo "-e QUERY_LOGGING=$QUERY_LOGGING_TF"; fi)\
            $(if [[ "$WEBTHEME" != "deafult-light" ]]; then echo "-e WEBTHEME=$WEBTHEME"; fi)\
            $(if [[ "$INTERFACE" != "no" ]]; then echo "-e INTERFACE=$INTERFACE"; fi)\
            $(if [[ "$DNSMASQ_LISTENING" != "" ]]; then echo "-e DNSMASQ_LISTENING=$DNSMASQ_LISTENING"; fi)\
            $(if [[ "$WEB_PORT" != "no" ]]; then echo "-e WEB_PORT=$WEB_PORT"; fi)\
            $(if [[ "$WEB_BIND_ADDR" != "no" ]]; then echo "-e WEB_BIND_ADDR=$WEB_BIND_ADDR"; fi)\
            $(if [[ "$SKIPGRAVITYONBOOT" != "no" ]]; then echo "-e SKIPGRAVITYONBOOT=$SKIPGRAVITYONBOOT"; fi)\
            $(if [[ "$CORS_HOSTS" != "no" ]]; then echo "-e CORS_HOSTS=$CORS_HOSTS"; fi)\
            $(if [[ "$CUSTOM_CACHE_SIZE" != "10000" ]]; then echo "-e CUSTOM_CACHE_SIZE=$CUSTOM_CACHE_SIZE"; fi)\
            $(if [[ "$FTL_CMD" != "no" ]]; then echo "-e FTL_CMD=$FTL_CMD"; fi)\
        docker.io/pihole/pihole:$PIHOLE_VERSION

} | whiptail --gauge "PLEASE WAIT FOR INSTALL TO COMPLETE" $WHIPSIZE 0