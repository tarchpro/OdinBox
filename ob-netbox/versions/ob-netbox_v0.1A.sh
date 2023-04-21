#! /bin/bash

### INSTALL COCKPIT-PODMAN && git
dnf install cockpit-podman git -y
dnf install cockpit-navigator -y

### CREATE PODMAN NETWORK
podman network create netbox1POD

### CREATE PODMAN POD
podman pod create --name=netbox1POD --network=netbox1POD -p 56300:8000

### Make Directories
mkdir -p /var/ob/netbox1 \
    /var/ob/netbox1/postgres/netbox-postgres-data \
    /var/ob/netbox1/postgres/env \
    /var/ob/netbox1/netbox/netbox-media-files \
    /var/ob/netbox1/netbox/configuration \
    /var/ob/netbox1/netbox/reports \
    /var/ob/netbox1/netbox/scripts \
    /var/ob/netbox1/netbox/env \
    /var/ob/netbox1/redis/netbox-redis-cache-data \
    /var/ob/netbox1/redis/netbox-redis-data \
    /var/ob/netbox1/redis/env

### GIT ENVIRONMENT VARIABLES
git clone -b release https://github.com/netbox-community/netbox-docker.git

### COPY ENV FILES TO THEIR RESPECTIVE FILES
cp ./netbox-docker/env/netbox.env /var/ob/netbox1/netbox/env
cp ./netbox-docker/env/postgres.env /var/ob/netbox1/postgres/env
cp ./netbox-docker/env/redis-cache.env /var/ob/netbox1/redis/env
cp ./netbox-docker/env/redis.env /var/ob/netbox1/redis/env
cp -r ./netbox-docker/configuration/* /var/ob/netbox1/netbox/configuration

### TEMPORARY DISABLE SELinux
setenforce 0

### CREATE POSTGRES CONTAINER
podman run -d \
--name netbox1_postgres \
--pod=netbox1POD \
-v /var/ob/netbox1/postgres/netbox-postgres-data:/var/lib/postgresql/data \
--env-file /var/ob/netbox1/postgres/env/postgres.env \
docker.io/postgres:15-alpine

### CREATE REDIS CONTAINER
podman run -d \
--name netbox1_redis \
--pod=netbox1POD \
-v /var/ob/netbox1/redis/netbox-redis-data:/data \
--env-file /var/ob/netbox1/redis/env/redis.env \
docker.io/redis:7-alpine \
sh -c 'redis-server --requirepass "$REDIS_PASSWORD"'

### MODIFY ALLOWED HOSTS FILE
sed -i "s/^ALLOWED HOSTS *=.*/ALLOWED HOSTS = ['*']/g" /var/ob/netbox1/netbox/netbox-media-files/configuration.py

### CREATE NETBOX CONTAINER
podman run -d \
--name=netbox1_netbox \
--pod=netbox1POD \
-e PUID=0 \
-e PGID=0 \
-e TZ=Etc/UTC \
-e SUPERUSER_EMAIL=admin@admin.net \
-e SUPERUSER_PASSWORD=admin \
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

### EXIT NOTES
echo "System is sucessfully installed, the default credentials are"
echo "USERNAME: admin"
echo "PASSWORD: admin"
echo "   "
echo "Make sure to update this IMMEDIATELY!"
echo "   "
echo "   "
echo "The Default Port This is mapped to is 56300"