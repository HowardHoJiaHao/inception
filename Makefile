
-include ./srcs/.env

COMPOSE_FILE=./srcs/docker-compose.yml

all:
	@echo "Help: "
	@echo "make init to initialize volumes"
	@echo "make up to start docker containers"
	@echo "make down to remove docker containers"

init:
	@if ! grep -q "^127.0.0.1[[:space:]]\+${DOMAIN_NAME}$$" /etc/hosts; then \
		echo "Setting up domain name ..." \
	 	sudo sh -c 'echo "127.0.0.1	${DOMAIN_NAME}" >> /etc/hosts'; \
	 fi
	@echo "Setting up volumes ..."
	@bash -c 'mkdir -p "$(HOME)/${MYUSR}/data/"{wp,mariadb}'
	@echo "Volumes created in $(HOME)/${MYUSR}/data !"

up:
	@docker compose -f $(COMPOSE_FILE) up --build -d

down:
	@docker compose -f $(COMPOSE_FILE) down

stop:
	@docker compose -f $(COMPOSE_FILE) stop

.PHONY: all init up down stop

# docker compose up -d mariadb
# docker compose stop mariadb

# docker compose exec mariadb mariadb -u root -p
# use wordpress
# SHOW TABLES;
# exit
