FROM debian:bookworm

# INSTALLATION
# nginx 	 		: webserver
# openssl			: for https
# gettext-base: for envsubst
RUN apt-get update && apt-get install -y \
	nginx \
	openssl \
	gettext-base \
	&& rm -rf /var/lib/apt/lists/*

# create dir once
RUN mkdir -p /etc/nginx/ssl

# -r : system user
# -g : group
RUN groupadd -g 1001 -r nginx && \
	useradd -u 1001 -r -g nginx -s /usr/sbin/nologin nginx

# Fix permissions for log directories
RUN chown -R nginx:nginx /var/lib/nginx /var/log/nginx

# use own nginx & init script
COPY ./conf/nginx.conf /etc/nginx/nginx.conf.template
COPY --chmod=750 ./tools/init.sh /init.sh

EXPOSE 443

ENTRYPOINT [ "/init.sh" ]