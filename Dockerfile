FROM ubuntu:trusty

RUN apt-get update && apt-get install -y nginx nginx-extras apache2-utils

ENV USERNAME=${USERNAME:-} PASSWORD=${PASSWORD:-}

VOLUME /media
COPY webdav.conf /etc/nginx/conf.d/default.conf
RUN rm /etc/nginx/sites-enabled/*

COPY entrypoint.sh /
RUN chmod +x entrypoint.sh
CMD /entrypoint.sh && nginx -g "daemon off;"
