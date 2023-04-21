# Install Snipe-IT

1. Install podman support in cockpit

		sudo dnf install cockpit-podman

1. Make podman network

		sudo podman network create -d macvlan --subnet=SUBNET --gateway=GATEWAY -o parent=INTERFACE_NAME NETWORK_NAME

1. Create podman pod

		sudo podman pod create --name=PODNAME --network=NETWORK_NAME -p 56298:80 -p 56299:443

1. Create Directories

		sudo mkdir -p /var/ob/snipeit1/mariadb/config
		sudo mkdir -p /var/ob/snipeit1/snipeit/config

1. Create MariaDB container

		sudo podman run -d \
		--name=snipeit1_mariadb \
		--pod=snipeit1POD \
		-e TZ=Etc/UTC \
		-e MYSQL_ROOT_PASSWORD=Pie11Alpha \
		-e MYSQL_DATABASE=snipeit1 \
		-e MYSQL_USER=snipeit1 \
		-e MYSQL_PASSWORD=Pie11Alpha \
		-v /var/ob/snipeit1/mariadb/config:/config \
		--restart unless-stopped \
		lscr.io/linuxserver/mariadb:latest

1. Create Snipe-IT container

		sudo podman run -d \
		--name=snipeit1_snipeit \
		--pod=snipeit1POD \
		-e TZ=Etc/UTC \
		-e MYSQL_PORT_3306_TCP_ADDR=snipeit1_mariadb \
		-e MYSQL_PORT_3306_TCP_PORT=3306 \
		-e MYSQL_DATABASE=snipeit1 \
		-e MYSQL_USER=snipeit1 \
		-e MYSQL_PASSWORD=Pie11Alpha \
		-e APP_URL=* \
		-v /var/ob/snipeit1/snipeit/config:/config \
		--restart unless-stopped \
		lscr.io/linuxserver/snipe-it:latest