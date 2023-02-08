# Using debian penultimate version to run the Container 
FROM debian:buster

RUN apt-get update && apt install -y nginx openssl && mkdir -p /run/nginx && mkdir -p /etc/nginx/ssl && \
       openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
       -out /etc/nginx/ssl/cjulienn.crt \
       -keyout /etc/nginx/ssl/cjulienn.key \
       -subj "/C=BE/ST=BECentral/L=Brussels/O=19 School/OU=cjulienn/CN=cjulienn/"

# copy config file nginx.conf 
COPY ./conf/nginx.conf /etc/nginx/conf.d

# open port 443 with expose cmd
EXPOSE 443

# trigger shell cmds to start nginx
CMD ["nginx", "-g", "daemon off;"]
