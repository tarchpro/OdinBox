# Install Podman
1. Install podman support in cockpit

		sudo dnf install cockpit-podman

1. Make podman network

		sudo podman network create -d macvlan --subnet=SUBNET --gateway=GATEWAY -o parent=INTERFACE_NAME NETWORK_NAME

1. Create podamn pod

		sudo podman pod create --name=PODNAME --network=NETWORK_NAME -p 56298:80 -p 56299:443 -p 56300:8080 -p 56301:8000

1. Make Holding Directory

		sudo mkdir -p /var/ob/netbox1

1. Make Postgres Directory

		sudo mkdir -p /var/ob/netbox1/postgres/netbox-postgres-data
		sudo mkdir -p /var/ob/netbox1/postgres/env

1. Make Netbox Directory

		sudo mkdir -p /var/ob/netbox1/netbox/netbox-media-files
		sudo mkdir -p /var/ob/netbox1/netbox/configuration
		sudo mkdir -p /var/ob/netbox1/netbox/reports
		sudo mkdir -p /var/ob/netbox1/netbox/scripts
		sudo mkdir -p /var/ob/netbox1/netbox/env

1. Make Redis Directory

		sudo mkdir -p /var/ob/netbox1/redis/netbox-redis-cache-data
		sudo mkdir -p /var/ob/netbox1/redis/netbox-redis-data
		sudo mkdir -p /var/ob/netbox1/redis/env

1. Get the github file for enviroment variables

		git clone -b release https://github.com/netbox-community/netbox-docker.git

1. Copy the Environment Variables to their respective files

		sudo cp ./netbox-docker/env/netbox.env /var/ob/netbox1/netbox/env
		sudo cp ./netbox-docker/env/postgres.env /var/ob/netbox1/postgres/env
		sudo cp ./netbox-docker/env/redis-cache.env /var/ob/netbox1/redis/env
		sudo cp ./netbox-docker/env/redis.env /var/ob/netbox1/redis/env
		sudo cp -r ./netbox-docker/configuration/* /var/ob/netbox1/netbox/configuration

1. Disable SELinux

	Go into SELinux in cockpit and disable the service. It will prevent file alterations for the podman containers.

1. Start the Postgres Service

		sudo podman run -d \
		--name netbox1_postgres \
		--pod=netbox1POD \
		-v /var/ob/netbox1/postgres/netbox-postgres-data:/var/lib/postgresql/data \
		--env-file /var/ob/netbox1/postgres/env/postgres.env \
		docker.io/postgres:15-alpine

1. Start the Redis Service

		sudo podman run -d \
		--name netbox1_redis \
		--pod=netbox1POD \
		-v /var/ob/netbox1/redis/netbox-redis-data:/data \
		--env-file /var/ob/netbox1/redis/env/redis.env \
		docker.io/redis:7-alpine \
		sh -c 'redis-server --requirepass "$REDIS_PASSWORD"'

1. Start the Netbox Service

		sudo podman run -d \
		--name=netbox1_netbox \
		--pod=netbox1POD \
		-e PUID=0 \
		-e PGID=0 \
		-e TZ=Etc/UTC \
		-e SUPERUSER_EMAIL=oranclay@clayfam.tech \
		-e SUPERUSER_PASSWORD=Pie11Alpha \
		-e ALLOWED_HOST=['*'] \
		-e DB_NAME=netbox \
		-e DB_USER=netbox \
		-e DB_PASSWORD=J5brHrAXFLQSif0K \
		-e DB_HOST=netbox1_postgres \
		-e DB_PORT=5432 \
		-e REDIS_HOST=netbox1_redis \
		-e REDIS_PORT=6379 \
		-e REDIS_PASSWORD=H733Kdjndks81 \
		-e REDIS_DB_TASK=0 \
		-e REDIS_DB_CACHE=1 \
		-v /var/ob/netbox1/netbox/netbox-media-files/:/config \
		--restart unless-stopped \
		lscr.io/linuxserver/netbox:latest
