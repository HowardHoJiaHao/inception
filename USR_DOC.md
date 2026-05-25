## Introduction
<div align="left">
  <p><em>This documentation is intended for users to run the container services.</em></p><br>
</div>

## Table of Contents
- [Overview](#overview)
- [How to Start & Stop Project](#how-to-start--stop-project)
- [Accessing Wordpress Admin Panel](#how-to-access-wordpress-admin-panel)
- [Managing Credentials](#where-to-manage-credentials)
- [Debugging](#debugging)

<br>

## Overview
#### Services provided:
- **NGINX** : Configured as reverse proxy, handling SSL/TLS v1.2, TLSv1.3, serves the website only via HTTPS, port `443`
- **Wordpress** : Configure wordpress as website interface with php-fpm installed to manage cgi scripts
- **MariaDB** : Configured as isolated container to store Wordpress data

<br>

## How to Start & Stop Project
In project root directory,
- Start project with:
	```bash
	make up
	```
- Stop project with:
	```bash
	make down
	```

<br>

## How to Access Wordpress Admin Panel
Access wordpress admin panel via:
```bash
https://<login>.42.fr/wp-admin
```

Access usual wordpress page via:
```bash
https://<login>.42.fr
```

<br>

## Where to manage credentials
| Credentials | Location |
|---|---|
| wordpress username | `.env` |
| wordpress userpass | `/secrets/credentials.txt` |

You need to create these files by duplicating `/secrets.example` and `.env.example` file

<br>

## Debugging
Check if services are running correctly by:
```bash
docker ps
```
It should list all 3 containers : nginx, wordpress, mariadb and their status