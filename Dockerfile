FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.12

# set version label
ARG branch=master
LABEL build_version="Linuxserver.io/forked version"
LABEL maintainer="Ceyal"

# package versions
RUN \
 echo "**** install packages ****" && \
 apk add --no-cache  \
	curl \
	fontconfig \
	memcached \
	netcat-openbsd \
	php7-ctype \
	php7-curl \
	php7-dom \
	php7-gd \
	php7-ldap \
	php7-mbstring \
	php7-memcached \
	php7-mysqlnd \
	php7-openssl \
	php7-pdo_mysql \
	php7-phar \
	php7-simplexml \
	php7-tokenizer \
	php7-tidy \
	qt5-qtbase \
	tar \
	ttf-freefont \
	wkhtmltopdf && \
 echo "**** tidy bug fix ****" && \
 curl -s \
	http://dl-cdn.alpinelinux.org/alpine/v3.7/community/x86_64/tidyhtml-libs-5.4.0-r0.apk | \
	tar xfz - -C / && \
 rm -f /usr/lib/libtidy.so.5.6.0 && \
 echo "**** configure php-fpm ****" && \
 sed -i 's/;clear_env = no/clear_env = no/g' /etc/php7/php-fpm.d/www.conf && \
 echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php7/php-fpm.conf 

RUN \
 echo "**** fetch bookstack ****" && \
 mkdir -p\
	/var/www/html && \
 curl -o \
 /tmp/bookstack.tar.gz -L \
	"https://github.com/PolyJapan/BookStack/archive/${branch}.tar.gz" && \
 tar xf \
 /tmp/bookstack.tar.gz -C \
	/var/www/html/ --strip-components=1 && \
 echo "**** install  composer ****" && \
 cd /tmp && \
 curl -sS https://getcomposer.org/installer | php && \
 mv /tmp/composer.phar /usr/local/bin/composer && \
 echo "**** install composer dependencies ****" && \
 composer install -d /var/www/html/ && \
 echo "**** cleanup ****" && \
 rm -rf \
	/root/.composer \
	/tmp/*

# copy local files
COPY root/ /

# ports and volumes
VOLUME /config
