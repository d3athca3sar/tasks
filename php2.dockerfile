FROM debian:buster-slim AS build-php
RUN apt-get update -y --force-yes  \
    && apt-get upgrade -y --force-yes  \
    && apt-get install -y --force-yes \
    autoconf \
    build-essential \
    re2c \
    bison \
    libenchant-dev \
    freetds-dev \
    libxml2-dev \
    libsqlite3-dev \
    libonig-dev \
    libssl-dev \
    pkg-config \
    curl \
    wget \
    git \
    ca-certificates \
    libcurl4-openssl-dev \
    libjpeg-dev \
    libpng-dev \
    libxpm-dev \
    libfreetype6-dev \
    libvpx-dev \
    libgmp-dev \
    libsodium-dev \
    libzip-dev \
    libbz2-dev \
    libicu-dev \
    libonig-dev \
    libreadline-dev \
    libxslt1-dev \
    libtidy-dev \
    libkrb5-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /usr/src/php
RUN git clone -b PHP-8.0 https://github.com/php/php-src.git .
RUN ./buildconf --force
RUN ./configure \
    --prefix=/usr/local/php \
    --with-config-file-path=/usr/local/php/etc \
    --enable-mbstring \
    --enable-zip \
    --enable-bcmath \
    --enable-pcntl \
    --enable-ftp \
    --enable-exif \
    --enable-calendar \
    --enable-sysvmsg \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-wddx \
    --with-curl \
    --with-mcrypt \
    --with-iconv \
    --with-gmp \
    --with-pspell \
    --with-gd \
    --with-jpeg-dir=/usr \
    --with-png-dir=/usr \
    --with-zlib-dir=/usr \
    --with-xpm-dir=/usr \
    --with-freetype-dir=/usr \
    --with-t1lib=/usr \
    --enable-gd-native-ttf \
    --enable-gd-jis-conv \
    --with-openssl \
    --with-mysql-sock=/var/run/mysqld/mysqld.sock \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd \
    --with-gettext=/usr \
    --with-zlib=/usr \
    --with-bz2=/usr \
    --with-recode=/usr \
    --with-libxml-dir=/usr \
    --enable-soap \
    --enable-xml \
    --enable-intl \
    --with-icu-dir=/usr \
    --with-enchant=/usr \
    --with-readline \
    --enable-pdo \
    --with-pdo-odbc=unixODBC,/usr \
    --with-pdo-pgsql \
    --with-pdo-sqlite \
    --with-pdo-dblib=/usr \
    --enable-sockets \
    --enable-sysvmsg \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-shmop \
    --enable-pcntl \
    --with-pear \
    --with-tidy \
    --with-xmlrpc \
    --enable-fpm \
    --with-fpm-user=www-data \
    --with-fpm-group=www-data
RUN make && make install
RUN cp php.ini-production /usr/local/php/etc/php.ini
RUN cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf
RUN cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
RUN echo "/usr/local/php/sbin/php-fpm" >> /etc/init.d/rc.local
CMD ["/usr/local/php/sbin/php-fpm", "-F"]