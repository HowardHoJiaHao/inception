#!/bin/sh

# exits if any command fails
set -e

# read secrets
_DB_ROOT_PWD=$(cat /run/secrets/db_root_passwd)
_DB_PWD=$(cat /run/secrets/db_passwd)

echo "> Initializing env in init.sql ..."
DB_PWD="$_DB_PWD" DB_ROOT_PWD="$_DB_ROOT_PWD" envsubst '${DB_NAME} ${DB_USER} ${DB_PWD} ${DB_ROOT_PWD}' < /etc/mysql/init.sql.template > /etc/mysql/init.sql

# debug
# cat < /etc/mysql/init.sql

echo "> Starting mysqld ..."
exec mysqld --user=mysql --bind-address=0.0.0.0

# can run this after docker compose up to check port:
# docker exec -it mariadb ss -tlnp | grep 3306