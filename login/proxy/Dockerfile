FROM nginx:1.17
LABEL maintainer "fraoustin@gmail.com"

ENV SET_CONTAINER_TIMEZONE false 
ENV CONTAINER_TIMEZONE "" 

# manage user www-data
RUN usermod -u 1000 www-data

# manage start container
COPY ./src/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN mkdir /usr/share/docker-entrypoint.pre
RUN mkdir /usr/share/docker-entrypoint.post
COPY ./src/00_init.sh /usr/share/docker-entrypoint.pre/00_init.sh
RUN chmod +x -R /usr/share/docker-entrypoint.pre

# install extra nginx
RUN apt-get update && apt-get install -y \
        apache2-utils \
        nginx-extras \
    && rm -rf /var/lib/apt/lists/* 

COPY ./src/default.conf /etc/nginx/conf.d/default.conf
RUN rm /etc/nginx/sites-enabled/default

RUN mkdir /auth
COPY ./src/www/* /auth/

# add cmd nginx
COPY ./src/cmd/addauth.sh /usr/bin/addauth
COPY ./src/cmd/rmauth.sh /usr/bin/rmauth
RUN chmod +x /usr/bin/addauth
RUN chmod +x /usr/bin/rmauth

ENV THEIAUSER user
ENV THEIAPASSWORD pass

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["app"]
