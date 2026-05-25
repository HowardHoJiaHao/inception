## Introduction
<div align="left">
  <p><em>This documentation is intended for developers to setup, build and manage the container services.</em></p><br>
</div>


## Project Directory
```bash
inception/
├── test.sh							# tests to check connectivity
├── Makefile
├── .gitignore
├── secrets/						# create this by duplicating secrets.example
└── srcs/
    ├── docker-compose.yml
    ├── .env						# create this by duplicating .env.example
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/50-server.conf	# MariaDB server config
        │   └── tools/init.sh		# DB initialisation script
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/www.conf		# PHP-FPM config
        │   └── tools/setup.sh		# WordPress install script
        └── nginx/
            ├── Dockerfile
            ├── conf/nginx.conf		# Nginx + TLS config
            └── tools/setup.sh		# SSL cert generation script
```
<br>

## Prerequisites
[Docker Engine](https://docs.docker.com/engine/install/) and [Docker Compose](https://docs.docker.com/compose/install/) must be installed on your machine.
- macOS users may install [Docker Desktop](https://docs.docker.com/desktop/) or install `docker` & `docker compose` in a virtual machine, such as [Colima](https://github.com/abiosoft/colima/blob/main/README.md), [UTM](https://mac.getutm.app/), or vm of your choice

Verify your installation by running:
```bash
docker --version
```

<br>

## Setup Instructions
#### 1. Set up environment & secrets
#### 1.1 Set up environment
- Copy `.env.example` and rename to `.env`
- Change `<login>` into your chosen name, fill in the remaining fields with your chosen credentials. Ensure no spaces in between values.

#### 1.2 Set up secrets
- Copy `secrets.example`folder and rename to `secrets`
- Add your own password in `db_passwd.txt`, `db_root_passwd.txt`
- Fill in the fields with your chosen credentials in `credentials.txt`


#### 2. Init & Build Project using Makefile
- In the project root directory, run
	```sh
	# first time run
	make init && make up
	```
-	for subsequent runs:
	```sh
	# subsequent run
	make up
	```


<br>

## Docker Compose Commands
|| Commands |
|---|---|
| **List active containers** | docker ps |
| **List docker image** | docker images |
| **Build & initialize docker** | docker compose up --build |
| **Stop docker** | docker compose stop |
| **Remove docker** | docker compose down |
<!-- | **Start docker** | docker compose start | -->
<!-- | **Start in bash** | docker start -i <container_name> | -->
| **List all docker volumes** | docker volume ls |
<!-- | **Remove container** | docker rm <container_name> | -->
<!-- | **Remove images** | docker rmi <image_name> | -->
| **Execute single command** | docker exec <container_name> `<cmd>` |
<!-- | **Check container processes** | docker top <container_name> | -->
| **** |  |


<br>

## Data Persistence
Identify where project data is stored. By defaullt named volumes will persist `docker compose down`
|||
|---|---|
| 1. **Navigate to ./srcs** | `cd ./srcs` |
| 2. **List all docker volumes** | `docker volume ls` |
| 3. **Get volume path** | `docker inspect <volume-name>` |
|||

it should return something like this, find volume path at `Mountpoint` or `Options: device`

```json
	{
			"CreatedAt": "2026-03-22T10:55:29+08:00",
			"Driver": "local",
			"Labels": {
					"com.docker.compose.config-hash": "<some_hash>",
					"com.docker.compose.project": "<proj_name>",
					"com.docker.compose.version": "5.0.2",
					"com.docker.compose.volume": "<volume_name>"
			},
			"Mountpoint": "/var/lib/docker/volumes/<volume_name>/_data",
			"Name": "<volume_name>",
			"Options": {
					"device": "/home/path/data/<volume_name>",
					"o": "bind",
					"type": "none"
			},
			"Scope": "local"
	}
```

<br>

## Others
### How to login to Wordpress admin
```bash
https://<login>.42.fr/wp-admin
```
<br>

### How to login to MariaDB
```bash
mysql -u root -p<your-db-password>
```

#### Testing MariaDB root commands
```bash
SELECT CURRENT_USER();
SELECT SESSION_USER();
SHOW PROCESSLIST;
```