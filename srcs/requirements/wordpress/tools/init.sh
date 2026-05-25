#!/bin/sh

if wp-cli --version --allow-root > /dev/null; then
    echo "> WP-CLI is working"
fi

DB_PWD=$(cat /run/secrets/db_passwd)
WP_ADMIN_PWD=$( grep "^wp_admin_pwd=" /run/secrets/wp_passwd | cut -d'=' -f2 )
WP_USER_PWD=$( grep "^wp_user_pwd=" /run/secrets/wp_passwd | cut -d'=' -f2 )

echo "> Changing directory to /var/www/html ... "
cd /var/www/html

# 1. downloads wordpress, init .php files
echo "> Checking if wordpress installed ... "
if ! wp-cli core is-installed --allow-root 2>/dev/null; then
	wp-cli core download --version=6.9.4 --allow-root
fi


# 2. init database user in config file
if [ ! -f "/var/www/html/wp-config.php" ]; then
	echo "> Creating wp config file ... "
	wp-cli config create \
		--dbname="${DB_NAME}" \
		--dbuser="${DB_USER}" \
		--dbpass="${DB_PWD}" \
		--dbhost="${DB_HOST}" \
		--allow-root
fi

# 3. set up wordpress admin
wp-cli core install \
	--url="${WP_URL}" \
	--title="${WP_TITLE}" \
	--admin_user="${WP_ADMIN_USER}" \
	--admin_password="${WP_ADMIN_PWD}" \
	--admin_email="${WP_ADMIN_EMAIL}" \
	--allow-root

wp-cli option update siteurl "${WP_URL}" --allow-root
wp-cli option update home "${WP_URL}" --allow-root

# 4. set up normal user
if ! wp-cli user get "${WP_USER}" --allow-root > /dev/null 2>&1; then
	echo "> Creating wp user ..."
	wp-cli user create \
		"${WP_USER}" "${WP_USER_EMAIL}" \
		--user_pass="${WP_USER_PWD}" \
		--role="author" \
		--allow-root
fi

chown -R www-data:www-data /var/www/html/

echo "> Creating ready flag for healthcheck ..."
touch /tmp/wp-ready
echo "> ✅ Wordpress ready flag created at /tmp/wp-ready"

# 5. start php cgi
echo "> Running php-fpm in foreground ..."
exec php-fpm8.2 -F