# docker-php

This is a customized docker image of PHP FPM based on the official images. It is used for providing a local development environment.

**Please note:** This is mostly used internally, but I am happy if anyone finds this useful or provides improvements.

## Features

* Commonly used extensions are enabled:
  * `apcu`
  * `bz2`
  * `bcmath`
  * `exif`
  * `gd`
  * `gettext`
  * `imagick`
  * `intl`
  * `memcached`
  * `mysqli`
  * `opcache`
  * `pdo`
  * `pdo_mysql`
  * `pdo_pgsql`
  * `pdo_sqlite`
  * `pdo_sqlsrv`
  * `pgsql`
  * `redis`
  * `soap`
  * `sockets`
  * `sqlsrv`
  * `xdebug`
  * `xsl`
  * `zip`
* Configurability:
  * `*.ini` taken from `/usr/local/etc/php/conf.d.local` (samples in [conf.d](conf.d))
  * timezone taken from `$PHP_TIMEZONE` (default: `Europe/Berlin`)
* Other:
  * `composer-1`, `composer-2`/`composer`, and `n98-magerun2` preinstalled
  * UTF-8 locales built for `en_US`, `en_GB` and `de_DE`
  * file extensions not limited to `.php` (dangerous!)
  * ssmtp preconfigured as MTA which delivers to `mailcatcher:1025`

## Getting started

See [luzat/template-php](https://github.com/luzat/template-php) for example usage.

## Author

**Thomas Luzat** - [luzat.com](https://luzat.com/)

## License

This project is licensed under the [ISC License](LICENSE.md).
