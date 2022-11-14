FROM nginxinc/nginx-unprivileged
LABEL maintainer="John Ruiz <jruiz@johnruiz.com>"

# these arguments can be passed to 'docker build'
ARG VERSION=1.2.6.4

# we're going to setup php as root and the drop back to nginx
USER root

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -qq && \
    apt-get install -y -qq unzip curl php7.4-fpm php7.4-ldap php7.4-xml > /dev/null && \
    php -v && \
    mkdir /srv/docker-phpLDAPadmin && \
    mkdir /run/php && \
    chown nginx:nginx /run/php && \
    mkdir /etc/nginx/snippets && \
    touch /var/log/php7.4-fpm.log && \
    chown nginx:nginx /var/log/php7.4-fpm.log

# if /docker-entrypoint.sh finds a script that isn't executable, it skips it
# and we want to skip 10-listen-on-ipv6-by-default.sh because it re-writes
# the default.conf in /etc/nginx/conf.d
RUN chmod -x /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh

# exerpt from: https://hub.docker.com/_/nginx
# this image has a function, which will extract environment variables before
# nginx starts. By default, this function reads template files in 
# /etc/nginx/templates/*.template and outputs the result of executing envsubst
# to /etc/nginx/conf.d
COPY ./files/default.conf.template /etc/nginx/templates/

# the official nginx docker image doesn't contain `snippets/fastcgi-php.conf`
# or `fastcgi.conf` so I've stolen them from elsewhere and will copy them here
COPY ./files/fastcgi.conf /etc/nginx
COPY ./files/fastcgi-php.conf /etc/nginx/snippets

# we'll steal this idea for the phpLDAPadmin config/config.php
COPY ./files/config.php.template /srv/docker-phpLDAPadmin

# the underlying image will automatically run entrypoint scripts in /docker-entrypoint.d/*
COPY ./files/15-defaults.envsh /docker-entrypoint.d
COPY ./files/25-envsubst-on-php-config.sh /docker-entrypoint.d
COPY ./files/40-start-php-fpm.sh /docker-entrypoint.d

# define an FPM pool for PLA (PHP LDAP Admin) and remove the default www pool
COPY ./files/pla.conf /etc/php/7.4/fpm/pool.d
RUN rm /etc/php/7.4/fpm/pool.d/www.conf

WORKDIR /srv/docker-phpLDAPadmin
RUN curl -sSLO "https://github.com/leenooks/phpLDAPadmin/archive/refs/tags/$VERSION.zip" && \
    unzip -q "$VERSION.zip"

ENV PHP_LDAP_ROOT=/srv/docker-phpLDAPadmin/phpLDAPadmin-${VERSION}

# having setup PHP and phpldapadmin, make nginx own the folder and drop
# back to running as the unprivileged nginx user
RUN chown -R nginx:nginx /srv/docker-phpLDAPadmin
USER nginx

# keep the underlying image's ENTRYPOINT and CMD
