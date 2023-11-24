# syntax=docker/dockerfile:1

FROM php:8.2.12-fpm

LABEL org.opencontainers.image.source=https://github.com/luzat/docker-php

ENV PHP_INI_SCAN_DIR=/usr/local/etc/php/conf.d:/usr/local/etc/php/conf.d.local
ENV PHP_TIMEZONE=Europe/Berlin
ENV COMPOSER_MEMORY_LIMIT=-1

ADD https://files.magerun.net/n98-magerun2.phar /usr/local/bin/n98-magerun2.phar
ADD https://getcomposer.org/download/2.6.5/composer.phar /usr/local/bin/composer
ADD https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb /microsoft-prod.deb
ADD https://packages.microsoft.com/config/debian/12/prod.list /etc/apt/sources.list.d/microsoft-prod.list

RUN <<-EOF
  set -xe
  echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/02apt-speedup
  echo msodbcsql18 msodbcsql/ACCEPT_EULA boolean true | debconf-set-selections
  dpkg -i /microsoft-prod.deb
  rm /microsoft-prod.deb
  apt-get update
  apt-get dist-upgrade -y
  apt-get install -y \
    apt-transport-https \
    ghostscript \
    git \
    gnupg \
    graphicsmagick \
    libbz2-dev \
    libicu72 libicu-dev \
    libfreetype6 libfreetype6-dev \
    libjpeg62-turbo libjpeg62-turbo-dev \
    libmagickwand-6.q16 libmagickwand-6.q16-dev \
    libpng-dev \
    libxpm4 libxpm-dev \
    libwebp7 libwebp-dev \
    libmemcached11 libmemcachedutil2 libmemcached-dev \
    libpcre3 libpcre3-dev \
    libpq5 libpq-dev \
    libxml2-dev \
    libxslt1.1 libxslt1-dev \
    libzip4 libzip-dev \
    locales \
    libodbc1 msodbcsql18 odbcinst unixodbc unixodbc-dev \
    msmtp msmtp-mta \
    sudo \
    unzip
  curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash
  apt-get install -y \
    symfony-cli
  echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
  echo 'en_GB.UTF-8 UTF-8' >> /etc/locale.gen
  echo 'de_DE.UTF-8 UTF-8' >> /etc/locale.gen
  locale-gen
  MAKEFLAGS="-j$(nproc)" pecl install \
    apcu-5.1.23 \
    imagick-3.7.0 \
    memcached-3.2.0 \
    pdo_sqlsrv-5.11.1 \
    redis-6.0.2 \
    sqlsrv-5.11.1 \
    xdebug-3.2.2 \
    zip-1.22.3
  docker-php-ext-enable \
    apcu \
    imagick \
    memcached \
    pdo_sqlsrv \
    redis \
    sqlsrv \
    xdebug \
    zip
  docker-php-ext-configure gd \
    --with-freetype=/usr/include/ \
    --with-jpeg=/usr/include/ \
    --with-webp=/usr/include/ \
    --with-xpm=/usr/include/
  docker-php-ext-install -j$(nproc) \
    bcmath \
    bz2 \
    exif \
    gd \
    gettext \
    intl \
    mysqli \
    opcache \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    soap \
    xsl
  CFLAGS="$CFLAGS -D_GNU_SOURCE" docker-php-ext-install -j$(nproc) sockets
  sed -ri 's/^\s*;?\s*pm.max_children = .*$/pm.max_children = 32/' /usr/local/etc/php-fpm.d/www.conf
  echo 'security.limit_extensions =' >> /usr/local/etc/php-fpm.d/www.conf
  apt-get clean
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    libbz2-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmagickwand-6.q16-dev \
    libpng-dev \
    libpng-dev \
    libwebp-dev \
    libxpm-dev \
    libicu-dev \
    libmemcached-dev \
    libpcre3-dev \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    libzip-dev \
    unixodbc-dev
  chmod +rx /usr/local/bin/n98-magerun2.phar /usr/local/bin/composer
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/www/html
EOF

COPY msmtprc /etc/
COPY php.ini /usr/local/etc/php/

WORKDIR /var/www

