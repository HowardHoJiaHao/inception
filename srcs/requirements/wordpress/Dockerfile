FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	php8.2-fpm \
	php8.2-mysqli \
	curl \
	sendmail \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -o /usr/local/bin/wp-cli https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x /usr/local/bin/wp-cli

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY --chmod=750 ./tools/init.sh /init.sh

EXPOSE 9000

ENTRYPOINT [ "/init.sh" ]