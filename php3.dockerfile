FROM debian:buster-slim AS build-php
#packages (not even sure if we need all of these)
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
WORKDIR /usr/bin/php/src
#Clone that fucking php sourcecode.
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

#fucking around with php.ini
#OLD SHIT: COPY php.ini  /opt/php/php8/lib/php.ini
RUN cp php.ini-production /opt/php/php8/lib/php.ini \
    && sed '/;extension=xsl/a zend_extension=opcache' filename /opt/php/php8/lib/php.ini \
    && echo "zend_extension=/opt/php/php8/lib/php/extensions/no-debug-non-zts-20201009/opcache.so" >> /opt/php/php8/lib/php.ini \
    && echo "opcache.enable = 1" >> /opt/php/php8/lib/php.ini \
    && echo "opcache.enable_cli = 1" >> /opt/php/php8/lib/php.ini \
    && echo "opcache.memory_consumption = 128" >> /opt/php/php8/lib/php.ini \
    && echo "opcache.interned_strings_buffer = 8" >> /opt/php/php8/lib/php.ini \
    && echo "opcache.max_accelerated_files = 10000" >> /opt/php/php8/lib/php.ini \
    && echo "opcache.use_cwd = 0" >> /opt/php/php8/lib/php.ini \
    && echo "opcache.validate_timestamps = 0" >> /opt/php/php8/lib/php.ini \
    && echo "opcache.save_comments = 0" >> /opt/php/php8/lib/php.ini \
    && echo "opcache.load_comments = 0" >> /opt/php/php8/lib/php.ini \
    && echo "opcache.enable_file_override = 1" >> /opt/php/php8/lib/php.ini 
#fucking around with init.d and config
COPY php-8-fpm /etc/init.d/php-8-fpm
RUN chmod +x /etc/init.d/php-8-fpm \
    && update-rc.d php-8-fpm defaults \
    && cp /opt/php/php8/etc/php-fpm.conf.default /opt/php/php8/etc/php-fpm.conf \
    #&& echo ";include=/opt/php/php8/etc/php-fpm.d/*.conf" >>/opt/php/php8/etc/php-fpm.conf \
    && echo "pid = run/php-fpm.pid" >> /opt/php/php8/etc/php-fpm.conf \
    && echo "[www]" >> /opt/php/php8/etc/php-fpm.conf \
    && echo "user = www-data" >> /opt/php/php8/etc/php-fpm.conf \
    && echo "group = www-data" >> /opt/php/php8/etc/php-fpm.conf \
    && echo "listen = 0.0.0.1:8999" >> /opt/php/php8/etc/php-fpm.conf \
    && echo "pm = dynamic" >> /opt/php/php8/etc/php-fpm.conf \
    && echo "pm.max_children = 10" >> /opt/php/php8/etc/php-fpm.conf \
    && echo "pm.start_servers = 2" >> /opt/php/php8/etc/php-fpm.conf \
    && echo "pm.min_spare_servers = 2" >> /opt/php/php8/etc/php-fpm.conf \
    && echo "pm.max_spare_servers = 4" >> /opt/php/php8/etc/php-fpm.conf
CMD ["/etc/init.d/php-8-fpm", "start"]