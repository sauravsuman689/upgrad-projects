FROM ubuntu
LABEL maintainer="NGINX Docker Maintainers sauravsuman689"
RUN apt-get update && apt-get upgrade -y && apt-get install nginx -y
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf 
EXPOSE 80
WORKDIR /etc/nginx
ENTRYPOINT ["/bin/sh", "-c", "echo $(hostname -I) >>/var/www/html/index.html && nginx"]

