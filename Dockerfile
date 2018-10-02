FROM php:7.2.10-fpm

ENV \
  PHP_INI_SCAN_DIR=/usr/local/etc/php/conf.d:/usr/local/etc/php/conf.d.local \
  PHP_TIMEZONE=Europe/Berlin

RUN set -xe; \
  apt-get update; \
  apt-get dist-upgrade -y; \
  apt-get install -y \
    git \
    imagemagick \
    libfreetype6 libfreetype6-dev libjpeg62-turbo libjpeg62-turbo-dev libpng-dev \
    libmemcached11 libmemcachedutil2 libmemcached-dev \
    libxml2-dev \
    libpcre3 libpcre3-dev \
    ssmtp \
    sudo \
    libzip4 \
    libzip-dev \
    locales; \
  echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen; \
  echo 'en_GB.UTF-8 UTF-8' >> /etc/locale.gen; \
  echo 'de_DE.UTF-8 UTF-8' >> /etc/locale.gen; \
  locale-gen; \
  pecl install \
    apcu-5.1.12 \
    memcached-3.0.4 \
    redis-4.1.1 \
    xdebug-2.6.1 \
    zip-1.15.3 \
  docker-php-ext-enable \
    apcu \
    memcached \
    redis \
    xdebug \
    zip; \
  docker-php-ext-configure gd \
    --with-freetype-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/; \
  docker-php-ext-install -j$(nproc) \
    gd \
    mysqli \
    opcache \
    pdo \
    pdo_mysql \
    soap; \
  sed -ri 's/^\s*;?\s*pm.max_children = .*$/pm.max_children = 32/' /usr/local/etc/php-fpm.d/www.conf; \
  echo 'security.limit_extensions =' >> /usr/local/etc/php-fpm.d/www.conf; \
  apt-get clean; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
    libmemcached-dev \
    libxml2-dev \
    libzip-dev \
    libpcre3-dev; \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ssmtp.conf /etc/ssmtp/
COPY php.ini /usr/local/etc/php/

VOLUME /var/www
