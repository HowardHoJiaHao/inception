FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	mariadb-server \
	gettext-base \
	&& rm -rf /var/lib/apt/lists/*

# create directory to run mariadb
# default mariadb runs at /run/mysqld/mysqld.sock
RUN mkdir -p /run/mysqld /var/log/mysql && \
	chown -R mysql:mysql /run/mysqld /var/log/mysql

# use own config file
# rename to 99-server.cnf to keep original 50-server.cnf
# while overrides it by running after
COPY ./conf/50-server.conf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY ./tools/init.sql /etc/mysql/init.sql.template
COPY --chmod=750 ./tools/init.sh /init.sh

# expose mariadb default port
EXPOSE 3306

ENTRYPOINT [ "/init.sh" ]