FROM php:8.0.7-fpm

ENV \
  PHP_INI_SCAN_DIR=/usr/local/etc/php/conf.d:/usr/local/etc/php/conf.d.local \
  PHP_TIMEZONE=Europe/Berlin \
  COMPOSER_MEMORY_LIMIT=-1

ADD https://files.magerun.net/n98-magerun2.phar /usr/local/bin/n98-magerun2.phar
ADD https://getcomposer.org/download/1.10.22/composer.phar /usr/local/bin/composer-1
ADD https://getcomposer.org/download/2.1.3/composer.phar /usr/local/bin/composer-2
ADD https://github.com/symfony/cli/releases/download/v4.25.4/symfony_linux_amd64 /usr/local/bin/symfony

RUN set -xe; \
  echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/02apt-speedup; \
  apt-get update; \
  apt-get dist-upgrade -y; \
  apt-get install -y \
    apt-transport-https \
    gnupg; \
  curl -q https://packages.microsoft.com/keys/microsoft.asc | apt-key add -; \
  curl -q https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list; \
  apt-get update; \
  ACCEPT_EULA=Y apt-get install -y \
    ghostscript \
    git \
    graphicsmagick \
    libbz2-dev \
    libicu63 libicu-dev \
    libfreetype6 libfreetype6-dev \
    libjpeg62-turbo libjpeg62-turbo-dev \
    libpng-dev \
    libxpm4 libxpm-dev \
    libwebp6 libwebp-dev \
    libmemcached11 libmemcachedutil2 libmemcached-dev \
    libpcre3 libpcre3-dev \
    libpq5 libpq-dev \
    libxml2-dev \
    libxslt1.1 libxslt1-dev \
    libzip4 libzip-dev \
    locales \
    libodbc1 msodbcsql17 odbcinst unixodbc unixodbc-dev \
    msmtp msmtp-mta \
    sudo \
    unzip; \
  echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen; \
  echo 'en_GB.UTF-8 UTF-8' >> /etc/locale.gen; \
  echo 'de_DE.UTF-8 UTF-8' >> /etc/locale.gen; \
  locale-gen; \
  pecl install \
    apcu-5.1.20 \
    memcached-3.1.5 \
    pdo_sqlsrv-5.9.0 \
    redis-5.3.4 \
    sqlsrv-5.9.0 \
    xdebug-3.0.4 \
    zip-1.19.3; \
  docker-php-ext-enable \
    apcu \
    memcached \
    pdo_sqlsrv \
    redis \
    sqlsrv \
    xdebug \
    zip; \
  docker-php-ext-configure gd \
    --with-freetype=/usr/include/ \
    --with-jpeg=/usr/include/ \
    --with-webp=/usr/include/ \
    --with-xpm=/usr/include/; \
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
    sockets \
    xsl; \
  sed -ri 's/^\s*;?\s*pm.max_children = .*$/pm.max_children = 32/' /usr/local/etc/php-fpm.d/www.conf; \
  echo 'security.limit_extensions =' >> /usr/local/etc/php-fpm.d/www.conf; \
  apt-get clean; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    libbz2-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
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
    unixodbc-dev; \
  chmod +rx /usr/local/bin/n98-magerun2.phar /usr/local/bin/composer-1 /usr/local/bin/composer-2 /usr/local/bin/symfony; \
  ln -s composer-2 /usr/local/bin/composer; \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/www/html

COPY msmtprc /etc/
COPY php.ini /usr/local/etc/php/

WORKDIR /var/www
