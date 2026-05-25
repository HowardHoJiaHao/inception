## Inception
<div align="left">
  <p><em>This project has been created as part of the 42 curriculum by hho-jia-</em></p><br>
</div>

## Table of Contents
- [Description](#description)
- [Setup Instructions](#setup-instructions)
- [Documentation](#documentation)
- [Resources](#resources)
- [AI Usage](#ai-usage)

## Description
Inception is a 42 project about learning concepts of system administration and virtualization using Docker. Every image must be build from base OS (Debian or Alpine). By the end of project, we will learn to setup a functional service running in isolated containers, via docker-compose.yml and Dockerfiles.

### Main Design Requirements
**Containers:**
- **NGINX** : Configured as reverse proxy, handling SSL/TLS v1.2, TLSv1.3, serves the website only via HTTPS, port `443`
- **Wordpress** : Configure wordpress as website interface with php-fpm installed to manage cgi scripts
- **MariaDB** : Configured as isolated container to store Wordpress data

**Named Volumes:**
- **Wordpress Volume** : Stores wordpress frontend website files
- **MariaDB Volume** : Stores wordpress backend data

**Docker Network** :
- to isolate communication within required containers, preventing access between unrelated services

<details>
<summary><h3>Virtual Machines vs Docker</h3></summary>

<!-- ### Virtual Machines vs Docker -->
| | Virtual Machine | Docker Container |
|---|---|---|
| **Isolation** | Better isolation via hypervisor (eg. VMWare, VirtualBox) | Process-level isolation via kernel namespaces and cgroups, shared kernel requires careful configuration to avoid escapes |
| **Size** | Larger size, full OS | Smaller size, only install necessary packages |
| **Portablility** | Less portable, depends on hypervisor compatibility | Runs anywhere with Docker Engine |
| **Resource usage** | High, reserves RAM & CPU | Minimal, uses only what is needed |
| **Persistence** | Persistent by default | Ephemeral, uses volumes for persistent data |
| **Use Case** | Running multiple OS environment, legacy applications | Microservices, CI/CD pipelines, software development |
</details>

<details>
<summary><h3> Secrets vs Environment Variables </h3></summary>

| | Secrets | Environment Variables |
|---|---|---|
| **Purpose** | For sensitive data, such as password | For configuration, non-sensitive data |
| **Data Encoding** | Encrypted, better security | Plain text |
| **Accessibility** | Able to set permission since stored as file | Accessible via environment dump |
| **Access Path** | Access via `/run/secrets/<secret_name>`| Access via environment |
</details>

<details>
<summary><h3> Docker Network vs Host Network </h3></summary>

| | Docker Network | Host Network |
|---|---|---|
| **Isolation** | Full isolation, containers have own network space | No isolation, uses host network directly |
| **Port Mapping** | Must be explicitly mapped from host to container (`-p 8080:80`) | Not needed, host ports are directly accessible |
| **Port Conflict** | Multiple containers can use same port as it is isolated, no conflicts | Only one container can use the specific port |

</details>

<details>
<summary><h3> Docker Volumes vs Bind Mounts </h3></summary>

| | Docker Volumes | Bind Mounts |
|---|---|---|
| **Isolation** | Isolated from host filesystem | Container has direct access to host filesystem, depends on mount permission |
| **Management** | Managed by Docker (eg removing volumes) | Managed by user |
| **Location** | Managed by Docker | User needs to specify which directory path to mount |
| **Migration** | Easier to backup & migrate | Difficult, depends on host directory and structure |
| **Empty Behaviour** | Creates empty volume, can copy data from container if volume empty | Binds empty host directory, host overrides container existing contents |
| **Accidental Modification** | Less likely, hidden in `/var/lib/docker/`volumes | More likely, especially if mixed with common paths (eg. `Desktop/`) |

</details>

<br><br>

## Setup Instructions

#### 0. Prerequisites
- [Docker Engine](https://docs.docker.com/engine/install/) and [Docker Compose](https://docs.docker.com/compose/install/) must be installed on your machine.
- macOS users may install a virtual machine to run `docker` & `docker compose`, such as [Docker Desktop](https://docs.docker.com/desktop/), [Colima](https://github.com/abiosoft/colima/blob/main/README.md), [UTM](https://mac.getutm.app/), or other vm of your choice

#### 1. Clone the repository
```sh
git clone <repo-url> inception
cd inception
```
#### 2. Setup .env keys
- Copy `.env.example` and rename to `.env`
- Change `<login>` into your chosen name, fill in the remaining fields with your chosen credentials. Ensure no spaces in between values.

#### 3. Setup secrets
- Copy `secrets.example`folder and rename to `secrets`
- Add your own password in `db_passwd.txt`, `db_root_passwd.txt`
- Fill in the fields with your chosen credentials in `credentials.txt`

#### 4. Build and start container
```sh
# first time run
make init && make up

# consequent run
make up
```

#### 5.1 Access wordpress page
```bash
https://<login>.42.fr
```

#### 5.2 Access wordpress admin page
```bash
https://<login>.42.fr/wp-admin
```

<br>

## Other Notes
### What is TLS nginx
TLS is Transport Layer Security protocol within nginx.
- enable nginx to encrypt web traffic (using HTTPS), protect data from eavesdropping and tampering
- secure communication between clients (like web browsers) and the server

### What is PID 1
PID 1 run as first process. Responsible for:
- Reaping zombie processes
- Forwards signal such as SIGTERM & SIGINT to child process for graceful shutdown

If the executed cmd is not capable of handling signals, should start script with `tini -- your_script.sh` or add `init: true` in docker-compose file. 

Else starting script with PID 1 will not exit when signal received

<br>

## Documentation
- [User Documentation](USER_DOC.md)
- [Developer Documentation](DEV_DOC.md)
<br><br>

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

<br>

## AI Usage
AI was used in this project as a tool to aid learning about docker container concepts, docker commands, troubleshooting, drafting tests, extend references, and drafting documentations. All code was reviewed, understood, written and adapted manually.