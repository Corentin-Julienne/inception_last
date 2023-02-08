#!/bin/bash

# install mysql structure
mysql_install_db

# init the service
service mysql start

if [ -d "/var/lib/mysql/$MARIADB_DATABASE" ]
then 
	echo "There is already a DB"
else

# using debian script to install with a here_doc. see this tuto : https://linuxize.com/post/how-to-install-mariadb-on-debian-10/
mysql_secure_installation << EOF

Y
$MARIADB_ROOT_PASSWORD
$MARIADB_ROOT_PASSWORD
Y
n
Y
Y
EOF

#mysql -uroot launch mysql command line client, using echo and passing it to user with a pipe 
echo "GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '$MARIADB_ROOT_PASSWORD'; FLUSH PRIVILEGES;" | mysql -uroot

#Create database and user in the database for wordpress
echo "CREATE DATABASE IF NOT EXISTS $MARIADB_DATABASE; GRANT ALL ON $MARIADB_DATABASE.* TO '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_PASSWORD'; FLUSH PRIVILEGES;" | mysql -uroot

# Import sql database from a previous manual wordpress setup to avoid having to do it every time
mysql -uroot -p$MARIADB_ROOT_PASSWORD $MARIADB_DATABASE < /usr/local/bin/wordpress.sql

fi

# stopping the service
service mysql stop

exec "$@"
