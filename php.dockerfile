FROM debian:buster-slim AS build-php
#packages
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
    libsystemd-dev \
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
    g++ \
    make \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
#Clone php sourcecode.
FROM build-php AS gitclone
WORKDIR /usr/bin/php/src
RUN git clone https://github.com/php/php-src.git .\
    && ./buildconf \
    && ./configure \
        --prefix=/opt/php/php8 \
        --with-fpm-systemd \
        --enable-cli \
        --enable-fpm \
        --enable-intl \
        --enable-mbstring \
        --enable-opcache \
        --enable-sockets \
        --enable-soap \
        --with-curl \
        --with-freetype \
        --with-fpm-user=www-data \
        --with-fpm-group=www-data \
        --with-jpeg \
        --with-mysql-sock \
        --with-mysqli \
        --with-openssl \
        --with-pdo-mysql \
        --with-pgsql \
        --with-xsl \
        --with-zlib \
    && make -j4 && make install
#[Remove the source files  (Will make you cry while waiting for this to complete again)]    
    #&& rm -rf /usr/bin/php/src/php-src/* \

#editing php.ini
FROM gitclone as phpconfig
RUN cp php.ini-production /opt/php/php8/lib/php.ini \
    && tee -a /opt/php/php8/lib/php.ini <<EOF
    zend_extension=/opt/php/php8/lib/php/extensions/no-debug-non-zts-20201009/opcache.so 
    opcache.enable = 1 
    opcache.enable_cli = 1 
    opcache.memory_consumption = 128 
    opcache.interned_strings_buffer = 8 
    opcache.max_accelerated_files = 10000 
    opcache.use_cwd = 0 
    opcache.validate_timestamps = 0 
    opcache.save_comments = 0 
    opcache.load_comments = 0 
    opcache.enable_file_override = 1
EOF
COPY php-8-fpm /etc/init.d/php-8-fpm
#Editing the php-fpm.conf
FROM phpconfig as phpconfig2
RUN chmod +x /etc/init.d/php-8-fpm \
    && update-rc.d php-8-fpm defaults \
    && cp /opt/php/php8/etc/php-fpm.conf.default /opt/php/php8/etc/php-fpm.conf \
    && tee -a /opt/php/php8/etc/php-fpm.conf <<EOF
	pid = run/php-fpm.pid
	[www]
    user = www-data
    group = www-data
    listen = php:8999
    pm = dynamic
    pm.max_children = 10
    pm.start_servers = 2
    pm.min_spare_servers = 2
    pm.max_spare_servers = 4
EOF
CMD ["/opt/php/php8/sbin/php-fpm", "-F"]