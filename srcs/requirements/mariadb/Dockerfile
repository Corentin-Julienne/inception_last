# base image on debian penultimate version's image 
FROM debian:buster

# install mariadb and dependancies
RUN apt update && apt install -y mariadb-server && \
    mkdir -p /var/run/mysqld && chown mysql:mysql /var/run/mysqld && chmod 777 /var/run/mysqld

# allow execution of the mariadb script
COPY ./tools/setup_maria_db.sh /usr/local/bin
# move the wordpress.sql file to /usr/local/bin
COPY ./conf/wordpress.sql /usr/local/bin
# add execution rights of sql file and installation script
RUN chmod +x /usr/local/bin/setup_maria_db.sh && chmod +x /usr/local/bin/wordpress.sql
ENTRYPOINT [ "/usr/local/bin/setup_maria_db.sh" ]

# expose port 3036
EXPOSE 3036

#execute maria DB's daemon
CMD ["mysqld", "--bind-address=0.0.0.0"]
