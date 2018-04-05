FROM php:7.1.12-apache
MAINTAINER Ben Lamptey <ben@codepulse.co.uk> # install the PHP extensions we need - Help from a.contreras@catchdigital.com

RUN a2enmod rewrite

RUN apt-get update && apt-get install -y libpng-dev libjpeg-dev libpq-dev libldap2-dev mysql-client \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install gd mbstring opcache pdo pdo_mysql pdo_pgsql zip ldap bcmath

# Install xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Install imagick
RUN apt-get update && apt-get install -y libmagickwand-6.q16-dev --no-install-recommends \
		&& ln -s /usr/lib/x86_64-linux-gnu/ImageMagick-6.8.9/bin-Q16/MagickWand-config /usr/bin \
		&& pecl install imagick \
		&& echo "extension=imagick.so" > /usr/local/etc/php/conf.d/ext-imagick.ini

# set recommended PHP.ini settings # see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=60'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini


WORKDIR /var/www/html

RUN usermod -u 1000 www-data
RUN usermod -a -G users www-data

RUN chown -R www-data:www-data /var/www