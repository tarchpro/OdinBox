#!/bin/bash

### SET DEBUG
    set -x

### PUBLIC MAPPED PORTS
    NEXTCLOUDPUBLIC="80"
    NEXTCLOUDPRIVATE="80"
    COTURNTCPPUBLIC="3000"
    COTURNUDPPUBLIC="3000"
    COTURNTCPPRIVATE="5000"
    COTURNUDPPRIVATE="50000"

### UPDATE/UPGRADE
    dnf update -y
    dnf upgrade -y

### INSTALL PODMAN | COCKPIT | COCKPIT-PODMAN
    dnf install podman -y
    dnf install cockpit -y
    dnf install cockpit-podman -y

### ENABLE PODMAN | COCKPIT | COCKPIT-PODMAN
    systemctl enable podman
    systemctl enable cockpit
    systemctl enable cockpit-podman
    systemctl restart podmadn
    systemctl restart cockpit-podman
    systemctl restart cockpit

### CREATE "inbox" USER
    useradd --no-create-home inbox
    echo "4818lotUrNdKLM5J98CGQpI8Hftk7oaBBUa&jOP6*c3IEeE!*Vv3rnL5iXxnaU@AFDR^kAcYnqI4kkqYhH0%Ia9nj!b^dvC*WsaqwFY*Fhuo^GrUaVHh01UzoXpx*#5agE5lq8r8Sx^!*uVc5p49PEhUEc2JCDi1OpikDhCU#PaYTprm1QwZj6J86mC5elBtD4ckiS1p4h13!8Y9rItABEemjfUwLH7DeP6IVVvzTLSacl7!ej2O93jal%39*2lJ" | sudo passwd inbox --stdin

### CREATE PODMAN NETWORK
    podman network create --subnet=10.0.0.254/29 \
        --gateway=10.0.0.254 \
        --dns=9.9.9.9 nextcloudNET

### CREATE PODMAN POD
    podman pod create --name nextcloudPOD\
        --network nextcloudNET\
        -p $NEXTCLOUDPUBLIC:$NEXTCLOUDPRIVATE/tcp \
        -p $COTURNTCPPUBLIC:$COTURNTCPPRIVATE/tcp \
        -p $COTURNUDPPUBLIC:$COTURNUDPPRIVATE/udp

### CREATE ROOT DIRECTORY FOR THE PERSISTENCE | ASSIGN TO USER GROUP
    mkdir -p \
        /var/lib/ob/nextcloud1/{apps,config,data,themes} \
        /var/lib/ob/coturn1 \
        /var/lib/ob/onlyoffice1/{logs,data}

### CREATE THE NEXTCLOUD CONTAINER - https://hub.docker.com/_/nextcloud
    sudo -u inbox podman run -d \
        --name=nextcloud1 \
        --pod=nextcloudPOD \
        --user inbox \
        -v /var/lib/ob/nextcloud1/:/var/www/html/ \
        -v /var/lib/ob/nextcloud1/apps:/var/www/html/custom_apps \
        -v /var/lib/ob/nextcloud1/config:/var/www/html/config \
        -v /var/lib/ob/nextcloud1/data:/var/www/html/data \
        -v /var/lib/ob/nextcloud1/themes/:/var/www/html/themes/ \
        docker.io/nextcloud:production-fpm-alpine sh c 'adduser -D inbox && nextcloud1 start'

### CREATE THE ONLY OFFICE SERVER - https://hub.docker.com/r/onlyoffice/documentserver/
    podman run -i -d -t \
        --name=onlyoffice1 \
        --pod=nextcloudPOD \
        --user inbox \
        -v /var/lib/ob/onlyoffice1/logs:/var/log/onlyoffice \
        -v /var/lib/ob/onlyoffice1/data:/var/www/onlyoffice/Data \
        docker.io/onlyoffice/documentserver sh c 'adduser -D inbox && onlyoffice1 start'

### CREATE THE COTURN SERVER - https://hub.docker.com/r/coturn/coturn
    podman run -d \
        --name=coturn1 \
        --pod=nextcloudPOD \
        --user inbox \
        docker.io/coturn/coturn:4-alpine sh c 'adduser -D inbox && coturn1 start'

### FINISHED
    echo "The script has completed succesfully"


podman run -d \
        --name=nextcloud1 \
        --pod=nextcloudPOD \
        -v /var/lib/ob/nextcloud1/:/var/www/html/ \
        -v /var/lib/ob/nextcloud1/apps:/var/www/html/custom_apps \
        -v /var/lib/ob/nextcloud1/config:/var/www/html/config \
        -v /var/lib/ob/nextcloud1/data:/var/www/html/data \
        -v /var/lib/ob/nextcloud1/themes/:/var/www/html/themes/ \
        docker.io/nextcloud:production-fpm-alpine