# Inception

> 42 Common Core · Rank 05

*This project has been created as part of the 42 curriculum by hho-jia-*

## Table of Contents
- [Description](#description)
- [Architecture](#architecture)
- [Setup Instructions](#setup-instructions)
- [Testing](#testing)
- [Other Notes](#other-notes)
- [Documentation](#documentation)
- [Resources](#resources)
- [AI Usage](#ai-usage)

## Description
Inception is a 42 project about learning the concepts of system administration and virtualization using **Docker**. Every image must be built from a base OS (Debian or Alpine; this project uses `debian:bookworm`), not pulled ready-made. By the end of the project, we learn to set up a functional service running in isolated containers, using a `docker-compose.yml` and our own Dockerfiles.

### Main Design Requirements
**Containers:**
- **NGINX**: configured as a reverse proxy handling TLSv1.2 / TLSv1.3. It serves the website only via HTTPS, on port `443`
- **WordPress**: the website, with php-fpm installed to run the PHP scripts
- **MariaDB**: an isolated container that stores the WordPress data

**Named Volumes:**
- **WordPress Volume**: stores the WordPress website files
- **MariaDB Volume**: stores the WordPress database

**Docker Network:**
- isolates communication between the required containers, preventing access between unrelated services

<details>
<summary><h3>Virtual Machines vs Docker</h3></summary>

| | Virtual Machine | Docker Container |
|---|---|---|
| **Isolation** | Better isolation via hypervisor (eg. VMWare, VirtualBox) | Process-level isolation via kernel namespaces and cgroups, shared kernel requires careful configuration to avoid escapes |
| **Size** | Larger size, full OS | Smaller size, only install necessary packages |
| **Portability** | Less portable, depends on hypervisor compatibility | Runs anywhere with Docker Engine |
| **Resource usage** | High, reserves RAM & CPU | Minimal, uses only what is needed |
| **Persistence** | Persistent by default | Ephemeral, uses volumes for persistent data |
| **Use Case** | Running multiple OS environment, legacy applications | Microservices, CI/CD pipelines, software development |
</details>

<details>
<summary><h3>Secrets vs Environment Variables</h3></summary>

| | Secrets | Environment Variables |
|---|---|---|
| **Purpose** | For sensitive data, such as password | For configuration, non-sensitive data |
| **Data Encoding** | Encrypted, better security | Plain text |
| **Accessibility** | Able to set permission since stored as file | Accessible via environment dump |
| **Access Path** | Access via `/run/secrets/<secret_name>`| Access via environment |
</details>

<details>
<summary><h3>Docker Network vs Host Network</h3></summary>

| | Docker Network | Host Network |
|---|---|---|
| **Isolation** | Full isolation, containers have own network space | No isolation, uses host network directly |
| **Port Mapping** | Must be explicitly mapped from host to container (`-p 8080:80`) | Not needed, host ports are directly accessible |
| **Port Conflict** | Multiple containers can use same port as it is isolated, no conflicts | Only one container can use the specific port |
</details>

<details>
<summary><h3>Docker Volumes vs Bind Mounts</h3></summary>

| | Docker Volumes | Bind Mounts |
|---|---|---|
| **Isolation** | Isolated from host filesystem | Container has direct access to host filesystem, depends on mount permission |
| **Management** | Managed by Docker (eg removing volumes) | Managed by user |
| **Location** | Managed by Docker | User needs to specify which directory path to mount |
| **Migration** | Easier to backup & migrate | Difficult, depends on host directory and structure |
| **Empty Behaviour** | Creates empty volume, can copy data from container if volume empty | Binds empty host directory, host overrides container existing contents |
| **Accidental Modification** | Less likely, hidden in `/var/lib/docker/volumes` | More likely, especially if mixed with common paths (eg. `Desktop/`) |
</details>

## Architecture
```
               HTTPS :443 (TLSv1.2 / TLSv1.3, self-signed certificate)
  Browser  ─────────────────────────────────────────►  nginx
                                                          │  FastCGI :9000
                                                          ▼
                                                  wordpress (php-fpm)
                                                          │  SQL :3306
                                                          ▼
                                                       mariadb
```
- All three containers run on the private `inception` bridge network. Only NGINX publishes a port to the host (`443`).
- The WordPress files are stored in `$HOME/<MYUSR>/data/wp` (NGINX mounts the same volume read-only to serve them), and the database in `$HOME/<MYUSR>/data/mariadb`, using the `HOME` and `MYUSR` values from `srcs/.env`.
- Passwords are passed to the containers as **Docker secrets** (files under `/run/secrets/`), and the rest of the configuration comes from `srcs/.env`.

## Setup Instructions

#### 0. Prerequisites
- [Docker Engine](https://docs.docker.com/engine/install/) and [Docker Compose](https://docs.docker.com/compose/install/) must be installed on your machine.
- macOS users may install a virtual machine to run `docker` & `docker compose`, such as [Docker Desktop](https://docs.docker.com/desktop/), [Colima](https://github.com/abiosoft/colima/blob/main/README.md), [UTM](https://mac.getutm.app/), or another VM of your choice.

#### 1. Clone the repository
```sh
git clone https://github.com/HowardHoJiaHao/inception.git
cd inception
```

#### 2. Set up the `.env` keys
- Copy `srcs/.env.example` to `srcs/.env`.
- Remove the `#` in front of each key and fill in your values: your login, domain name and the database / WordPress settings. Make sure there are no spaces around the values.
- Use real-looking email addresses for `WP_ADMIN_EMAIL` and `WP_USER_EMAIL`. WordPress rejects an address whose domain part ends with `-` (for example `admin@hho-jia-.42.fr`), and the installation then fails.

#### 3. Set up the secrets
- Copy the `secrets.example` folder to `secrets`.
- Put your own passwords in `db_passwd.txt` and `db_root_passwd.txt`.
- Fill in the WordPress passwords in `credentials.txt`.

`srcs/.env` and `secrets/` are listed in `.gitignore`, so your real credentials are never committed.

#### 4. Build and start the containers
```sh
# first run
make init && make up

# next runs
make up
```

| Command | What it does |
|---|---|
| `make` | Shows the available commands |
| `make init` | Adds `127.0.0.1 <your domain>` to `/etc/hosts` (asks for `sudo`) and creates the data folders for the volumes |
| `make up` | Builds the images and starts the containers in the background |
| `make stop` | Stops the containers |
| `make down` | Stops and removes the containers |

#### 5.1 Access the WordPress page
```bash
https://<login>.42.fr
```

#### 5.2 Access the WordPress admin page
```bash
https://<login>.42.fr/wp-admin
```

## Testing
`test.sh` checks the running services:
```sh
./test.sh       # run all tests
./test.sh 7     # run one test
```

| Test | Checks |
|:---:|---|
| 1 | HTTPS connection |
| 2 | A simple PHP script |
| 3 / 4 | WordPress admin login page / login page |
| 5 | HTTP connection (should fail) |
| 6 | The certificate, using `openssl` |
| 7 / 8 | TLS v1.2 / TLS v1.3 connection |
| 9 | TLS v1.1 connection (should fail) |

> ⚠️ `./test.sh 100` stops and deletes **all** Docker containers, images, volumes and networks on the machine, not only this project's.

## Other Notes
### What is TLS in NGINX
TLS (Transport Layer Security) is the protocol NGINX uses to:
- encrypt web traffic (HTTPS), protecting data from eavesdropping and tampering
- secure the communication between clients (like web browsers) and the server

### What is PID 1
PID 1 is the first process started in a container. It is responsible for:
- Reaping zombie processes
- Forwarding signals such as SIGTERM & SIGINT to child processes for a graceful shutdown

If the command run is not able to handle signals, start the script with `tini -- your_script.sh` or add `init: true` in the docker-compose file. Otherwise a script running as PID 1 will not exit when it receives a signal.

## Documentation
- [User Documentation](USR_DOC.md)
- [Developer Documentation](DEV_DOC.md)

## Resources
- [Dockerfile practices explained!](https://youtu.be/ueTe-VQaD7c)
- [Docker compose manual: explains every attributes used in docker-compose file](https://docs.docker.com/reference/compose-file/services/)
- [Types of Docker volumes](https://www.datacamp.com/tutorial/docker-mount)
- [Official Docker volumes doc](https://docs.docker.com/engine/storage/volumes/)
- [`docker-compose` volumes](https://docs.docker.com/reference/compose-file/volumes/)
- [Configuring nginx.conf file & TLS](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [Docker secrets](https://docs.docker.com/reference/compose-file/secrets/)
- [Docker secrets FAQ](https://semaphore.io/blog/docker-secrets-management)
- [Docker Network Explained](https://www.datacamp.com/tutorial/docker-networking)
- [Docker Host Network vs Bridge Network](https://www.geeksforgeeks.org/devops/what-is-docker-network-host/)
- [PID 1 Explained](https://medium.com/@fernando.harsha2016/why-your-docker-container-wont-stop-gracefully-understanding-pid-1-and-process-management-569c44dce004)
- [Wordpress CLI cmds](https://developer.wordpress.org/cli/commands/)
- [Wordpress CLI user create](https://developer.wordpress.org/cli/commands/user/create/)
- [VM vs Container](https://www.designgurus.io/blog/virtual-machines-vs-containers)
- [Inception Medium Tutorial 1](https://medium.com/@imyzf/inception-3979046d90a0)
- [Inception Medium Tutorial 2](https://medium.com/@ssterdev/inception-42-project-part-ii-19a06962cf3b)

## AI Usage
AI was used in this project as a tool to aid learning about docker container concepts, docker commands, troubleshooting, drafting tests, extend references, and drafting documentations. All code was reviewed, understood, written and adapted manually.
