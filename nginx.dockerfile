FROM debian:buster-slim AS build-nginx
RUN apt-get update && apt-get install -y \
    build-essential \
    libpcre3 \
    libpcre3-dev \
    zlib1g-dev \
    libssl-dev \
    wget \
    zlib1g \
    libgd-dev \
    libxml2 \
    libxml2-dev \
    uuid-dev \
    systemd
WORKDIR /usr/src
RUN wget "http://nginx.org/download/nginx-1.20.0.tar.gz" \
    && tar -xvf nginx-1.20.0.tar.gz \
    && cd nginx-1.20.0 \
    && ./configure --prefix=/var/www/html --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --with-pcre  --lock-path=/var/lock/nginx.lock --pid-path=/var/run/nginx.pid --with-http_ssl_module --with-http_image_filter_module=dynamic --modules-path=/etc/nginx/modules --with-http_v2_module --with-stream=dynamic --with-http_addition_module --with-http_mp4_module \
    && make && make install \
    && rm -rf /var/lib/apt/lists/*
RUN rm /etc/nginx/nginx.conf

RUN echo "events {"> /etc/nginx/nginx.conf && \
    echo " worker_connections 1024;">> /etc/nginx/nginx.conf && \
    echo "}">> /etc/nginx/nginx.conf && \
    echo "http {">> /etc/nginx/nginx.conf && \
    echo "server {" >> /etc/nginx/nginx.conf && \
    echo "    listen 80;" >> /etc/nginx/nginx.conf && \
    echo "    server_name dockerWP;" >> /etc/nginx/nginx.conf && \
    echo "    location / {" >> /etc/nginx/nginx.conf && \
    echo "        proxy_pass http://wordpress:80;" >> /etc/nginx/nginx.conf && \
    echo "        proxy_set_header Host \$host;" >> /etc/nginx/nginx.conf && \
    echo "        proxy_set_header X-Real-IP \$remote_addr;" >> /etc/nginx/nginx.conf && \
    echo "        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;" >> /etc/nginx/nginx.conf && \
    echo "        proxy_set_header X-Forwarded-Proto \$scheme;" >> /etc/nginx/nginx.conf && \
    echo "    }" >> /etc/nginx/nginx.conf && \
    echo "}" >> /etc/nginx/nginx.conf && \
    echo "}" >> /etc/nginx/nginx.conf
CMD ["nginx", "-g", "daemon off;"]
