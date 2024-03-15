FROM debian:buster-slim AS build-php
RUN apt update && apt-get install -y \
    autoconf \
    re2c \
    bison \
    libsqlite3-dev \
    libpq-dev \
    libonig-dev \
    libfcgi-dev \
    libfcgi0ldbl \
    libjpeg-dev \
    libpng-dev \
    libssl-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libxpm-dev \
    libgd-dev \
    libmariadb-dev \
    libfreetype6-dev \
    libxslt1-dev \
    libpspell-dev \
    libzip-dev \
    git \
    gcc \
    make \
    && apt-get clean
   
WORKDIR /usr/bin/php/src
RUN cd /usr/bin/php/src \
    && git clone https://github.com/php/php-src.git \
    && cd php-src \
    && ./buildconf \
    && ./configure \
        --enable-fpm \
        --with-mysqli \
        --with-pdo-mysql \
        --with-openssl \
        --with-zlib \
    && make && make install \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/bin/php/src/php-src/*
CMD ["php-fpm"]