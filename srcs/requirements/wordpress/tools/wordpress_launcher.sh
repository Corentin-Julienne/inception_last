#!/bin/bash

if [ -f ./wp-config.php ]
then
	echo "wordpress has already been installed"
else
	# download last version of wordpress
	wget http://wordpress.org/latest.tar.gz
	tar xfvz latest.tar.gz
	rm -rf latest.tar.gz
	mv wordpress/* .
	rm -rf wordpress

	# config the php-config, using sed to edit sample and then transforming sample in wp-config.php
	sed -i "s/username_here/$MARIADB_USER/g" wp-config-sample.php
	sed -i "s/password_here/$MARIADB_PASSWORD/g" wp-config-sample.php
	sed -i "s/localhost/$MARIADB_HOSTNAME/g" wp-config-sample.php
	sed -i "s/database_name_here/$MARIADB_DATABASE/g" wp-config-sample.php
	mv wp-config-sample.php wp-config.php

	# create wordpress admin user and regular non admin user
	wp core install --allow-root --url=$DOMAIN_NAME --title=$WP_TITLE --admin_user=$MARIADB_USER --admin_password=$MARIADB_PASSWORD --admin_email=$WP_ADMIN_EMAIL
	wp user create --allow-root $WP_SECOND_USER $WP_SECOND_EMAIL --user_pass=$WP_SECOND_PASSWORD;
fi

exec "$@"
