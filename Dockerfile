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
    libpcre3 libpcre3-dev \
    libpq5 libpq-dev \
    libxml2-dev \
    libzip4 libzip-dev \
    locales \
    libodbc1 odbcinst unixodbc-dev \
    ssmtp \
    sudo \
    unzip; \
  echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen; \
  echo 'en_GB.UTF-8 UTF-8' >> /etc/locale.gen; \
  echo 'de_DE.UTF-8 UTF-8' >> /etc/locale.gen; \
  locale-gen; \
  pecl install \
    apcu \
    memcached \
    pdo_sqlsrv \
    redis \
    sqlsrv \
    xdebug \
    zip; \
  docker-php-ext-enable \
    apcu \
    memcached \
    pdo_sqlsrv \
    redis \
    sqlsrv \
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
    pdo_pgsql \
    pgsql \
    soap; \
  sed -ri 's/^\s*;?\s*pm.max_children = .*$/pm.max_children = 32/' /usr/local/etc/php-fpm.d/www.conf; \
  echo 'security.limit_extensions =' >> /usr/local/etc/php-fpm.d/www.conf; \
  apt-get clean; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
    libmemcached-dev \
    libpcre3-dev \
    libpq-dev \
    libxml2-dev \
    libzip-dev \
    unixodbc-dev; \
  EXPECTED_SIGNATURE="$(curl -q https://composer.github.io/installer.sig)"; \
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
  ACTUAL_SIGNATURE="$(php -r "echo hash_file('SHA384', 'composer-setup.php');")"; \
  [ "$EXPECTED_SIGNATURE" = "$ACTUAL_SIGNATURE" ]; \
  php composer-setup.php --install-dir=/usr/local/bin --filename=composer; \
  rm -rf composer-setup.php /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/www/html

COPY ssmtp.conf /etc/ssmtp/
COPY php.ini /usr/local/etc/php/

WORKDIR /var/www
