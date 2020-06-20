FROM php:5.5.38-fpm

ENV \
  PHP_INI_SCAN_DIR=/usr/local/etc/php/conf.d:/usr/local/etc/php/conf.d.local \
  PHP_TIMEZONE=Europe/Berlin

RUN set -xe; \
  apt-get update; \
  apt-get dist-upgrade -y; \
  apt-get install -y \
    git \
    imagemagick \
    libicu52 libicu-dev \
    libfreetype6 libfreetype6-dev libjpeg62-turbo libjpeg62-turbo-dev libpng-dev \
    libmemcached11 libmemcachedutil2 libmemcached-dev \
    libmcrypt4 libmcrypt-dev \
    libpcre3 libpcre3-dev \
    libpq5 libpq-dev \
    libxml2-dev \
    libxslt1.1 libxslt1-dev \
    libzip2 libzip-dev \
    locales \
    msmtp msmtp-mta \
    sudo \
    unzip; \
  echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen; \
  echo 'en_GB.UTF-8 UTF-8' >> /etc/locale.gen; \
  echo 'de_DE.UTF-8 UTF-8' >> /etc/locale.gen; \
  locale-gen; \
  pecl install \
    apcu-4.0.11 \
    memcached-2.2.0 \
    redis-2.2.8 \
    xdebug-2.5.5 \
    zip-1.19.0; \
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
    intl \
    mcrypt \
    mysql \
    mysqli \
    opcache \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    soap \
    xsl; \
  sed -ri 's/^\s*;?\s*pm.max_children = .*$/pm.max_children = 32/' /usr/local/etc/php-fpm.d/www.conf; \
  echo 'security.limit_extensions =' >> /usr/local/etc/php-fpm.d/www.conf; \
  apt-get clean; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
    libicu-dev \
    libmcrypt-dev \
    libmemcached-dev \
    libpcre3-dev \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    libzip-dev; \
  curl -q -o /usr/local/bin/n98-magerun.phar https://files.magerun.net/n98-magerun.phar; \
  curl -q -o /usr/local/bin/n98-magerun2.phar https://files.magerun.net/n98-magerun2.phar; \
  chmod +x /usr/local/bin/n98-magerun.phar /usr/local/bin/n98-magerun2.phar; \
  EXPECTED_SIGNATURE="$(curl -q https://composer.github.io/installer.sig)"; \
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
  ACTUAL_SIGNATURE="$(php -r "echo hash_file('SHA384', 'composer-setup.php');")"; \
  [ "$EXPECTED_SIGNATURE" = "$ACTUAL_SIGNATURE" ]; \
  php composer-setup.php --install-dir=/usr/local/bin --filename=composer; \
  rm -rf composer-setup.php /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/www/html

COPY msmtprc /etc/
COPY php.ini /usr/local/etc/php/

WORKDIR /var/www
