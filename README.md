# **Inception**

## **Goal of the project**
---

The project "Inception" of the 42 School is based on Docker. You will need to set up a LEMP stack (For Linux, Nginx, MariaDB, PHP) with Wordpress. Each service will be located inside a Docker container. 

## **Docker main concepts**
--- 

A container is a standard unit of software that packages up code and all its dependencies so the application runs quickly and reliably from one computing environment to another. The containers are not a Docker invention, but Docker is used to simplify the process and run several containers on a smooth way.

### *Difference between a Container and a Virtual Machine (VM)*
---

Containers share the machine’s OS system kernel and therefore do not require an OS per application. However, VMs need to have their dedicated OS, so having having several VMs in a single computer might produce some performance issues. In other words, containers are a lightweight solution. 

The advantages of Containers over VMs are :
- lightweight (we speak about Mbs instead of GBs for VMs)
- fast to boot (no need to "charge" the OS features several times, because kernel is shared)

The advantages of Vms over Containers are :
- Containers, because of shared kernel, can't work for different OS environment (indeed you can, but only if you run Containers on top of a VM)

VMs and Containers also share some key features :
- isolation (you just kill the VM or Container in case of problem, for instance, without affecting the whole system)

### *write a Dockerfile*
---

A Dockerfile is a text file that has a series of instructions on how to build your image. It supports a simple set of commands that you need to use in your Dockerfile. A Dockerfile is like a Makefile for Docker Image.

### *Dockerfiles main instructions*
---

You can find avery good overview of the main Dockerfile at this GitHub repository : https://github.com/vbachele/Inception

ENTRYPOINT vs CMD

CMD allows to add more arguments when running `docker run` . However, in the case of ENTRYPOINT we cannot override the ENTRYPOINT instruction by adding command-line parameters to the `docker run` command.

### *Docker Networks : how they are working* ###

Docker uses a CNM (Controller Network Model) to provide networking for controllers. We can use a lot of network drivers types provided by Docker with its CNM.

- bridge : the default option. Dockers make a default network, attributing an IP address to every container/service. Used mostly when your app runs in standalone containers thats need to communicate.
- host : Removes the network isolation between Docker host and containers. Not to use for Inception project.
- none : No network at all. Containers are conpletely isolated from one another. Usefulness ?
- overlay : creates an internal private network that spans access all the node participating in the swarm cluster. Docker Swarn not explained in that tutorial.
- macvlan : Gives a container a MAC address, making it appears as a physical device.

### *Volumes in relation to Docker Compose* ###

You have to understand several concepts to understand volumes. Volumes are used by Docker to store persistant, stateful data. Container should contain itself only stateless data. 

Among the concept you need to understand there is :

- Bind mounts : When you use a bind mount, a file or directory on the host machine is mounted into a container. It has quite some performance limitation compared to hte volumes you should use instead.
- The difference between bind mounts and volumes : volumes are situated outside of the containers (and are therefore permanents, and not limitated to the life cycle of the container)

How to create and manage docker volumes : 

- By implicit creation, using this syntax : ```- v <source>:<destination>:<options>```. If the source is a path that was used before, Docker will use a mount bind. If the source is a name, Docker tries to find the volume or create one if one cannot be found
- By explicit creation, using this syntax : ```docker volume create --name <the_name_you_want_to_give>```
- Using Docker compose, the most easy and reusable way. See the docker_compose.yml file to have a better understanding of the docker-compose functionning. Check this paragraph below to see an extract in showing how to setup docker volumes.

````
version: "3.2"
services:
	web:
		image: nginx:latest
		ports:
			-8080:80
		volumes:
			- ./target:/usr/share/nginx/html
````

The containers and hosts in the above configuration uses volumes in the services definition (web) to mount ```./target```from the host to  ```/usr/share/nginx/html``` of the container. This is a bind mount. 

A better way to do it with a proper volume will be to write something like this :

````
version: "3.2"
services:
	web:
		image: nginx:latest
		ports:
			- 8080:80
		volumes:
			- html_files: /usr/share/nginx/html
	
	web1:
		image: nginx:latest
		ports:
			- 8080:80
		volumes:
			- html_files: /usr/share/nginx/html
	
	volumes:
		html_files:

````

In this example, you declare a volume named html_files and use it in both web and web1 service. Multiple containers can mount the same volumes.

Running ```docker-compose up``` will create a volume named ```<project_name>_html_files``` if it doesn't already exist. Then run ```docker-compose ls``` to list the two volumes created, starting with the project name. 

You also have the possibility to manage the volume outside of the docker-compose file, but you will still need to declare them under volumes and set the property ```external: true```. 

````
version: "3.2"
services:
	web:
		image: nginx:latest
		ports:
			- 8080:80
		volumes:
			- html_files: /usr/share/nginx/html/
	
	volumes:
		html_files:
			external: true
````

If you don't have html_files, you can use the ```docker volume create html_files```to create it. When add external, Docker will find out if the volume exists, but. if it doesn't, an error will be reported.

### *Docker Best Practices* ###

For a more comprehensive article about this topic, see : https://cloud.google.com/architecture/best-practices-for-building-containers.

The goal of this subpart is helping you designing smaller and resilient images, to improve Docker performance. Security is a topic of importance too...

- Run a single service per container
- Properly handle PID, signal handling, and zonmbie processors (see chapter about it in the NGINX setup part below)
- Optimize the image for Docker build. Docker uses a cache system, and build an image layer by layer. In practical terms, that means that if you modify a Dockerfile, Docker will execute only the steps that were modified and the steps after. That means you should : 1) place the Docker command that are more likely to change at the end AND 2) you should group some commands whenever possible (do not use 500 RUN commands...)

There are some other mediumly important good practices such as :
- remove unnecessary tools
- build the smallest image possible (including using a lighter image using the FROM command)

Those are important for performance issues, but also for security (less room for software vulnerabilities)

## **Tutorial for Inception**
---

### *Install a Virtual Machine (VM) where to run the project*
---

You have to complete the project using a VM based on a Linux OS. However, the choice of the distro is completely up to you. I used the last Debian LTS (called Bullseye, version 11). To upgrade the performance of the VM, do not forget to install the guest additions. It will also helps to render a better and more accurate resolution. You can find the following tutorial : https://linuxways.net/debian/how-to-install-virtualbox-guest-additions-on-debian-11/.

You can use the command ````su```` in the terminal to access the root user (with the root password). You will need it to update the hosts file and for every command which requires sudo (by default, the user is not pertaining to sudo in Debian 11).

I recommand you to add the main non admin user to the sudo group. 

Download all the updates of the system for security reasons, then you will have to install Docker and modify the host to add your domain name.

To modify your host, file, open file ````/etc/hosts```` with vim as a super user (root) to be able to modify it, then add the following line : ````127.0.0.1 cjulienn.42.fr```` 

You will also have to install the Docker Engine on the VM. I personnaly chose to install it with the command line. The instructions are on page : https://docs.docker.com/engine/install/debian/.


#### setting up share folders
---

It is more convenient to write the script in VSC and then use it in your Debian host. You will need shared folder for this. First, enable the guest additions (link to the tutorial above). Then, go to the settings of your VM, go to shared folder, add one, make it permanent and do not specify the location. It will be present at the following path : /media/ (once you reboot your Debian host). The name of the shared folder will be sf_name_of_your_folder. This concise tutorial might helps you : https://carleton.ca/scs/tech-support/troubleshooting-guides/creating-a-shared-folder-in-virtualbox/.

#### setting up an SSH connection
---

In order to be able to send and receive info between guest and host, we need to provide a working SSH connection. 
You can check the relevant part of this tutorial : (https://baigal.medium.com/born2beroot-e6e26dfb50ac). PD : the ip adress if not necessarily 127.0.0.1 but can be anything else. Use this command to find out :
````
sudo service sshd status
````

You will need to provide the login of guest machine in order to open an SSH connection, plus the guest password. Generally when situated in the host machine, just write something like :
````
ssh guest_login@127.0.0.1 -p 22
```` 

#### several problems encountered with VM and VirtualBox configuration
---

Problem 1 : Sometimes VirtualBox won't update itself which can cause the guest machine unability to launch. It will triggers an error message like : NS_ERROR_FAILURE (0x80004005). If this happens, you can follow this troubleshooting tutorial : https://www.mytecbits.com/apple/macos/virtualbox-error-ns_error_failure-0x80004005.
Problem 2 : Should you use several types of keyboards (such as working on your AZERTY keyboard from your personal PC or Mac and switch to the school Mac for correction), you may need to change the keyboard layout. Follow this tutorial : https://vitux.com/debian_keyboard_layout/#:~:text=An%20alternative%20and%20the%20quickest,shortcut%20from%20the%20keyboard%20settings.

## **NGINX**
---

### *What is NGINX*
---

NGINX is like a gateway that stands between the Internet and your back-end infrastructure. It solves the problem of having multiple requests fron clients to server. If you have too much traffic, there will be a lot of latency. So, you might think it is a good idea to have multiple instances of your website/software running on several ports of your server to increase performance. However, how will your client know in what port it is better to connect ? That where NGINX is useful. As stated before, it will act like a control tower. Client will connect on a single port to NGINX. NGINX will then request data on server with using the appropriate port. If some data are frequently requested, NGINX can store it in its cache to reduce latency and avoid the necessity to request data from the server itself.

### *NGINX subtilities*
---

NGINX can be used as a load balancer, meaning that it will make the link between client and different servers/ports, balancing it so the client can fetch data from the optimal server, or at least an available one (in order to avoid bottlenecks and important loading times).

NGINX is falselly labelled as a web server, but in fact is a gateway between the Internet and your backend infrastructure.

NGINX can also be used as a reverse proxy. In a standard proxy, the server doesn't know the client. In the reverse proxy, this is quite the opposite. The client does not know the server. Most of interaction is between the reverse proxy and the server(s). Load balancing is a feature, among many, of reverse proxy (and quite the most used feature of NGINX).

### *NGINX configuration*
---

NGINX configuration is quite straightforward. It has to be configured using a ```nginx.conf``` test file. How to write such a file is described in the following paragraphs.

#### what is needed by the subject
---

- One container NGINX with TLSv1.2 or TLSv1.3 only (we chose TLSv1.3). Http connection on port 80 are strictly prohibited (you have to force the use of https on port 443).

#### What is TLSv1.3
---

Transport Layer Security (TLS) encrypts data sent over the Internet to ensure that eavesdroppers and hackers are unable to see what you transmit which is particularly useful for private and sensitive information such as passwords, credit card numbers, and personal correspondence.

##### TLS Principles and Functionning
---

TLS is a cryptographic protocol that provides end-to-end security of data sent between applications over the Internet. 
It should be noted that TLS does not secure data on end systems. It simply ensures the secure delivery of data over the Internet, avoiding possible eavesdropping and/or alteration of the content. TLS is normally implemented on top of TCP in order to encrypt Application Layer protocols such as HTTP, FTP, SMTP and IMAP.

Note : TLS is what's used by HTTPS and is represented in web browsers as a locker on the left upper side of the browser, next to the URL bar.

#### What is FastCGI and how to configure it
---

According to its Wikipedia's page, FastCGI is a binary protocol for interfacing interactive programs with a web server. It is a variation on the earlier Common Gateway Interface (CGI). FastCGI's main aim is to reduce the overhead related to interfacing between web server and CGI programs, allowing a server to handle more web page requests per unit of time.

### How to write nginx.conf file
---

The file nginx.conf is used to configure nginx. To comply with the instructions of the subject, you only needs a server part (between brackets). Inside this server, you need to specify :
- the port you want to open (all the traffic between internet and NGINX will go throughout this port)
- add the location of the ssl key and certificate (made during the execution of the relevant Dockerfile execution)
- add the server name (AKA domain name, here ```login.42.fr```)
- add the ssl protocols you want to use (such as TLS v1.3 here)
- add the root (where is located the root of the relevant files to serve to client)
- add the index (what are the files you need to serve to the client, located at path specified by root)
- add location brackets (see : https://www.digitalocean.com/community/tutorials/nginx-location-directive)

The port directive is quite easy. You have to indicate the port 443 (see directly on the ````nginx.conf``` file for more informations about the syntax). 

You also have to configure fastcgi directives. Fastcgi_pass allows NGINX to know where to forward request from the client. You have to write the ip/service and associated port. You will also have to pass some parameters to ensure fastcgi will handle the request in an appropriate manner. You will have to use fastcgi_param. NGINX will update some variable regarding the request you are making. For instance, ````$request_method```` will allways contains the http method requested by the client. The ````SCRIPT_FILENAME```` parameter will be a combination of ````$document_root$fastcgi_script_name```` and ````fastcgi_index```` directive.

You also need to use ````fastcgi_index```` which will be put to ````ìndex.php```` in that case.

This will result in :

````
location ~.\php$ 
{
	fastcgi_param REQUEST_METHOD $request_method;
	fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
	fastcgi_index index.php;
}
````

Be careful, no inheritance applies here ! If you have different snippets of code with common config parts, you have to declare it once per scope. No global scope inheritance applies ! However, you could use two types of files, fastcgi_params and fastcgi.conf, which are NGINX files put there by the developpers to be included to the context with standard params for convenience. With the directive include fastcgi_params, you will need to include fastcgi_params, you will still need to include ````fastcgi_params SCRIPT_FILENAME```` afterwards.

So your context should ressemble to something like that :

`````
location ~\.php$ 
{
	fastcgi_pass 	wordpress:9000;
	fastcgi_index	index.php;
	include			fastcgi_params;
	fastcgi_param	SCRIPT_FILENAME $document_root$fastcgi_script_name
}
`````

#### NGINX location
---

- You can use try_files_directive in your location directive : https://linuxhint.com/use-nginx-try_files-directive/.


#### Daemons, NGINX, PID1 and containerization
---

To write the NGINX related Dockerfile, we need to understand some important concepts. 

Daemons in UNIX OSes are processes running in the background. They usually perform tasks without user intervention to maintain the good functionning on the OS. They usually are named with named ending with "d" like systemd for instance. 

Every process, including of course daemons, got a PID (process identificator). The top-most process in a UNIX system has PID (Process ID) 1 and is usually the init process. The Init process is the first userspace application started on a system and is started by the kernel at boottime. The kernel is looking in a few predefined paths (and the init kernel parameter). 

The role of processes identificated as PID1 is to reap every other processes when necessary (AKA, when they die), freeing resources. However, a signal such SIGINT or SIGKILL may not be able to have any effect on PID1. The Linux kernel handles signals differently for the process that has PID 1 than it does for other processes. In that, no problem ! PID1 processes is made to reap dead processes. It is like a control tower to reap resources when necessary, so if it is well made like in UNIX OSes, you shouldn't have memory leaks.

Now, daemons identificated by PID1 poses a unique probleme when interacting with containers. Containers is a concept that isolate processes in different namespaces. As a result, there are several sets of PIDS independant from one another. Docker and Kubernetes can only send signal to PIDs 1 inside every container. Yes, there is one PID1 for the OS itself, plus one PID1 per container ! 

As a result if those PID1 identificated processes do not reap (remove) every dead process and free memory in an appropriate manner, you can have zombie processes with allocated memory, which can lead to ressource deprivation over time (when using a lot of containers, for example, or making a lot of container operations like init and suppress a lot of times). 

You have several solutions to this problem explicated there : https://cloud.google.com/architecture/best-practices-for-building-containers#signal-handling. I chose the solution 1, the more convenient and easy, but you can also use tools such as tini to make such you won't have zombie processes.

### Write NGINX service Dockerfile

The Dockerfile for NGINX will allows the contruction of the NGINX custom docker image.

We used Debian Buster image to base our custom image from with the ```FROM``` command. Subjects also allows to use an Alpine Linux image.

Then, you will have to configure key parameters in several steps: 

- Update the packet managers apt with the ```update``` command and install ssl (in order to use TSL protocols) and of course nginx. Both can be installed using ```apt install``` with the Dockerfile ```RUN``` command.
- Allow ssl to generate a certificate and key to be used by TLS protocol. No intervention of the user should be necessary. See next paragraph to have more information about it.
- Copy the ```nginx.conf``` file into the relevant folder in the nginx service container (in ```/etc/nginx/conf.d```) using the Docker command ```COPY```.
- Create a folder NGINX won't be able to work if this folder does not exists. Use the the ```RUN``` command to execute this line of script and don't forget to add the flag ```-p``` in order to create intermediary folder if they do not exists. The path of the folder to create is : ```/run/nginx```.
- Allow the nginx service container to use port 443 as required by the subject using the ```EXPOSE``` command.
- Allow the execution of nginx without its daemon in order to avoid zombie processes (see next paragraph to have more information about this). The command would be ```CMD ["nginx", "-g", "daemon off;"]```.

#### Create a new SSL-key and certificate

- ```openssl``` : basic command to generate key and certificate using TLS.
- ```req``` : used to require a key certificate with the following option :
1. ```-x509``` : generates a self-signed certificate (no need to user intervention)
2. ```-days``` : number of days when key/certificate are valid. Add 365 after the flag (without ```-```)
3. ```-newkey rsa:4096``` : specify that we want to generate a key and a certificate at the same time. We indicate that we want to use the RSA protocol and a key of 4096 bytes long. 
4. ```-keyout``` : where to place the generated key
5. ```-out``` : where to place the generated certificate

So, you should have something like that : 
````



````

## **Wordpress**
---

### What is Wordpress
---

Wordpress is a Content Management System (CMS) powering about a third a websites in all the World Wide Web. Wordpress is written in PHP. 

### subject requirements
---

- A Docker container that contains WordPress + php-fpm (it must be installed and configured) only without nginx.

### what is Fastcgi and PHP-fpm (FastCGI Process Manager), and how does it works ?
---

PHP-fpm (Fastcgi Process Manager) is a popular Fastcgi implementation which works very well with NGINX. FastCgi is a binary protocol for interfacing interactive programs with a web server. Its main goal is to allow the web server to handle more requests per unit of times.

PHP-FastCgi Process Manager (PHP-FPM) is used to improve performance for websites using Wordpress. PHP-FPM is an advanced, highly efficient processor for the PHP scripting language. 

Let's take a look at it's architecture :
---

PHP is a high-level programing language. Therefore, it requires compilation before being send to a web server. The compilation can be done usign various tools and protocoles including suPHP, CGI and DSO.

PHP-FPM is organized as a master/parent process managing pools of individual worker processes. When the web server has a request for a PHP script, the web server uses a proxy, using a FastCgi connection to forward the request to the PHP-FPM service. A free PHP-FPM worker will accept the web server request. PHP-FPM then compiles and execute the PHP script, sending the output back to the web server once a PHP-FPM worker finishes handling a request, the system releases the worker and waits for a new request. The PHP-FPM master process dynamically creates and terminates worker processes, as traffic increases and decreases.

### how to configure WordPress
---

To configure Wordpress, you have to configure several important files :
- The Dockerfile to build your custom image, with an associated bash script for convenience (don't use 400 RUN commands...)
- The www.conf file to manage PHP-FPM pools of workers

Those steps are explained in the following paragraphs.

#### configure PHP-FPM with wordpress
---

The wordpress configuration includes a www.conf file which is used to configure pools of workers for PHP_FPM. The file itself should be located in ```/etc/php/<your-php-version>/fpm/pool.d/```. In your Dockerfile, you should move this file to the relevant location in your container. 

The file itself contains many comments and variables you don't have to modify. For instance, you should keep the [CONTINUE IMPLEMENTATION]

### create the bash script associated with the Dockerfile

You will need in that script to :
- download the latest version of wordpress
- move the www.conf file to the relevant location
- configure wp_config.php

Note : you can see in the script the ```exec "$@"```. It is not a trivial part of the script, you should pay attention to it. First, ```$@``` in bash and other Bourne-related shells refers to all of shell script command line arguments. So, ```$@``` actually is like an array of all the arguments. For exemple, if there is two lines in a shell script, then ```$@``` is equivalent to ```{$1, $"}```, ```$1``` being the first line and ```$2``` the second.

Using ```exec "$@"``` applies exec to all the script. Using exec will results in replacing the parent process, rather than having 2 different processes. As an example, if Redis is started without ```exec```, it will not receive a ```SIGTERM``` upon ```docker stop``` and won't get a chance to shut down clearly. In some cases, this can lead to data loss or zombie processes.

If you do start child processes (i.e. don't use exec), the parent process becomes responsible for handling signals as appropriate.

#### wp-config.php
---

Wp-config.php is a very important files for Wordpress to function properly. For instance, it gives the address of your database.

When you install Wordpress, you will be prompt to enter several informations, including for instance the location of your database storing the Wordpress data. However, it is not mandatory to use a GUI to tell Worpress those informations. What will Wordpress do is update the file called wp-config.php with those informations. You can, instead of using this GUI, modifying directly the file.

Note that sometimes you won't be able to execute the wp-config.php file directly. Wordpress provides a wp-sample.php file with a template for wp-config. What you can do is modify the wp-sample.php file (for example, with sed in a bash script), then moving the file to the wp-config.php location, modify the name of the file to wp-config.php and replace the wp-config.php by yours.

You will need to replace the following lines : 

````
	cd /var/www/html/wordpress
	sed -i "s/username_here/$MARIADB_USER/g" wp-config-sample.php
	sed -i "s/password_here/$MARIADB_PASSWORD/g" wp-config-sample.php
	sed -i "s/localhost/$MARIADB_HOSTNAME/g" wp-config-sample.php
	sed -i "s/database_name_here/$MARIADB_DATABASE/g" wp-config-sample.php
	cp wp-config-sample.php wp-config.php
````

You can find a tutorial on how to replace some portion of text by another using sed in this URL : https://www.cyberciti.biz/faq/how-to-use-sed-to-find-and-replace-text-in-files-in-linux-unix-shell/.

### Write the Wordpress Dockerfile

You will have to write the Wordpress Dockerfile in several steps :

- base it from the penultimate version of Alpine or Debian (I chose Debian:buster)
- install php, php-fpm and its dependancies
- install wget and curl (to be used in the bash script)
- install Wordpress-CLI (see next-paragraph)
- expose port 9000
- create the ```/run/php``` folder to able php to run (prerequisite)
- copy the script in ```usr/local/bin``` and add execution right using ```chmod```, then execute it using the ```ENTRYPOINTY``` command.
- putting the working directory to ```/var/www/html```
- execute php [GIVE MORE INFOS]

#### add WP-CLI (Wordpress Command Line Interface)
---

WP-CLI is a command line tool for Wordpress. It is more convenient to use by experienced users. It will be used to install Wordpress. Those lines in the dockerfile are used to download it :

````
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp
````

It will be usd by the bash script to modify wp-config.php file.

## **Maria DB**
---

Maria DB is a community branch of the MySQL project. It handle databases for stateful volumes. Even if stateful content is not well suited with Docker, you can add a volume containing the data to use with your containers. The MariaDB is used to store data relative to Wordpress.

### write the Dockerfile for MariaDB
---

How course, you have to base your MariaDB custom image in another Docker image (here debian:buster). 

- Download mariadb-server && mariadb-client
- Copy your .sh and the .sql on the /var/local/bin/ on your MariaDB container
- Give the right to execute your mysqld (which is the daemon for mysql)
- Launch your script to install mariaDB
- Then do a CMD to enable the database to listen to all the IPV4 adresses.

You also have to fix the following problems :
- if you can’t connect to local MySQL server through socket ‘/var/run/mysqld/mysqld.sock, it could trigger an error message. You have to fix that by following this tiny tutorial : http://cactogeek.free.fr/autres/DocumentationLinux-Windows/LinuxUbuntu/ProblemeMYSQL-mysqld.sockInexistant.pdf. See documentation below to have a good explanation of what a socker file is. 

#### What is the mysqld.sock SQL socket file ?
---

MySql and MariaDB manages connections to the database server through the use of a socket file, which is a special kind of file that facilitates communication between different processes. The MySql server's socket is named ```mysqld.sock```and is situated in Debian OS in ```/var/run/mysqld/``` directory.

### create a script triggered by your Dockerfile
---

The script will allow to create the database, give the appropriate rights to user and root, and start the database.

- First, we need to use the command ```mysql_install_db``` : it will initialize the MySQL data directory and creates the system tables that it contains, if they do not exist (doc here : https://mariadb.com/kb/en/mysql_install_db/).
- After that, it is mandatory to start the service. This tutorial will be useful : https://www.mysqltutorial.org/mysql-adminsitration/start-mysql/. You can choose between several methods to do that, but I personally chose to use service : ````service mysql start````
- 
- 

#### how to use mySqlCli
---

When using the MySql CLI, one way to pass a command to it from the bash script is to use ```echo "<type-command-there>" | mysql -uroot```. This way , the command will be passed to MySql CLI using root to have administration rights. 

Then, we need to give root and user all the privileges in order to be able to access the database. 


### write mariadb cnf file

According to the documentation, ther main config file can be situaated in multiples locations. MariaDB will look for a file call my.cnf in that order, until it finds a valid one :
- /etc/my.cnf
- /etc/mysql/my.cnf
- $MYSQL_HOME/my.cnf
- [datadir]/my.cnf
- ~/.my.cnf

In Debian OS, the cnf file is situated at /etc/my.cnf. This file include all the other subconf cnf files (using the syntax !include<path> in the folders conf.d and mariadb.conf.d).

You will need to add a configuration file or configuring an existing one. We chose to use the file called 50-server.cnf.

Those factors need to be modified :

- skip-networking : If set to 1, server does not listen for TCP/IP connections. Recommended to use only if only the local client can access to the database. In our case, BD needs to be accessed from other containers so this option needs to be put to 0 or false
- bind address : By default, MariaDB server listen to TCP/IP connections on all addresses. In some systems, such as Debian or Ubunut, the bind address is set to 127.0.0.1, which binds the server to listen to localhost only. Localhost refers to the container only, so we will need to change that to 0.0.0.0

The groups in configuration files are writtent with this syntax : [name_of_the_group]

For instance, [maria_db] will produce the following effect : read my MariaDB servers, not by MYSQL. It means that this effect will apply for all the instructions after this declaration (if another group is not declared before). Usually, config files are well documented.

You should note that if something is declared several times, only the last declaration will count.

In Debian Buster, you can modify the 50-server.cnf, which contains infos for mariaDB, server side. Add the following options (you can use CL tools like SED, for instance, or create your own file to replace the default file).

- port (put 3036 as requested by the subject)
- user : root [useful ?]

### create and manage your database with the file wordpress.sql

You will need to import a database when constructing a container :

The process we chose is to create a file wordpress.sql that will import the DB every time build a container with MariaDB. 

1) How to import/export a database from a sql file: 

MariaDB and MYSQL use a tool called mysqldumb to import and export databases :

- export a database : execute this command in your server, using this command : 
```
mysqldump -uUSERNAME -p DBNAME > database_name.sql
```

which can translate in your project by : 
```
mysqldump -u$MARIADB_USERNAME -p $MARIADB_DATABASE > wordpress.sql
```

- import a database : the process is quite similar and uses mysql command. You will needvto create a database before importing it with a file.sql (here called wordpress.sql). After you created the database, use the following syntax :
```
mysql -uUSERNAME -p DB_NAME < imported_db.sql
```

which can be translated into :
```
mysql $MARIADB_DATABASE < wordpress.sql
```

#### create a custom wordpress.sql file

You will need to comply with those rules, according to the subject :

- having a wordpress database with :
- 2 users (one administrator, one regular)
- the admin username can't contain admin or derivative (then, just call it root by default)

So, you will need to write those lines : 

1. create the MariaDB database
````
CREATE DATABASE `db_name`;
```
2. create the user (non-root one)

```
CREATE USER '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_PASSWORD';
```

3. grant privileges to the user

```
GRANT ALL ON $MARIADB_DATABASE 
```


https://www.hostinger.com/tutorials/mysql-show-users/ (see users in the db)
SELECT DISTINCT user FROM mysql.user;