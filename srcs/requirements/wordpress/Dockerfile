FROM debian:buster

#upgrade, update, install php, utils and dependencies
RUN apt update && apt -y install \
	wget \
	curl \
	php \
	php-mysql \
	php-fpm \
	&& curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

# Copy the .conf in the html directory
COPY ./conf/www.conf /etc/php/7.3/fpm/pool.d/

# enable running of php by creating relevant directory
RUN mkdir -p /run/php

# copy and move the bash script, give execution permission, then execute it
COPY "./tools/wordpress_launcher.sh" "/usr/local/bin"
RUN chmod +x /usr/local/bin/wordpress_launcher.sh 
ENTRYPOINT ["/usr/local/bin/wordpress_launcher.sh"]

# create a workdir for convenience
WORKDIR /var/www/html

# enable utilisation of port 9000
EXPOSE 9000

# exec wordpress
CMD ["/usr/sbin/php-fpm7.3", "-F"]
