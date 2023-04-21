#####    OB-STRAPI-v0.1A     #####

### CREATE NETWORK && POD

sudo -u inbox podman network create \
       	--subnet 10.0.10.254/24 \
       	--gateway 10.0.10.254 \
	--dns 9.9.9.9 \
	strapiNET

sudo -u inbox podman pod create \
	--name strapiPOD \
	--network strapiNET \
	-p 10000:8080

### MAKE DIRECTORIES

mkdir -p /var/ob/strapi/mariadb
mkdir -p /var/ob/strapi/


### CREATE MARIADB CONTAINER

sudo -u inbox podman run -d \
	--pod=strapiPOD \
	--name mariadb1 \
	-e MARIADB_USER=NQUz2r6Hi779jj2C \
	-e MARIADB_PASSWORD=ZufdV07tgypyAhGy77RZxY85gWyEzYJnnu1jwQVe39DX6cO2sHiHlEBX2JyKEa1FfSmKS22MpuEEX7n6T3uVfn9skyHDI5tPk7roOL6dYPIuE1uH25DHb8m5yQ60oIj7
	-e MARIADB_ROOT_PASSWORD=HwaEvZi13uCyLLsJfcHQJ3a8BKLuS61Aw5OY4U39sJ44HXhlWZ6LhoqxGOZWjkZcHXW2S6wgJN0iZ8t8LZeDFA8aNRY93JeJmWf37wvOLpXKuLEhW6FSnrfaivhMkH20jGp81BPgBFNlXO2n3xB8nZ2qS5uZLuqUsXpvh68uuWI3hwI9WWvmNAzjKFOgcbc61K36FnS4K4mM9eiyCULR4V72znlkTh3Y8x2LWhQLXxDcpv7z7xDjDyVEgs830Kjea \
	-v /var/ob/strapi/mariadb:/var/lib/mysql \
	docker.io/mariadb

### CREATE STRAPI CONTAINER

sudo -u inbox podman run -d \
	--pod=strapiPOD \
	--name strapi1 \
	docker.io/node:current-alpine3.17

### INSTALL STRAPI INSIDE strapi1

sudo -u inbox podman exec -it /bin/bash
	

