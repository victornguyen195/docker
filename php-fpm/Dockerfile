ARG PHP_VERSION

FROM php:${PHP_VERSION}-fpm

RUN apt-get update && apt-get install -y \
    default-mysql-client msmtp perl wget procps libzip-dev libpng-dev libjpeg62-turbo-dev libwebp-dev \
    libfreetype6-dev libicu-dev bash libxml2-dev libxslt1-dev vim autoconf automake \
    libtool patch git unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install gd bcmath mysqli pdo_mysql intl opcache exif zip xml soap sockets xsl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN wget https://getcomposer.org/composer-stable.phar -O /usr/local/bin/composer && chmod +x /usr/local/bin/composer

# Add install n98 to run cron
RUN wget https://files.magerun.net/n98-magerun2.phar \
    && chmod +x ./n98-magerun2.phar \
    && cp ./n98-magerun2.phar /usr/local/bin/

# Define the variable in the Dockerfile
ARG INSTALL_XDEBUG
ARG PHP_VERSION
# Pass the variable to the RUN command using ENV - Required to write after FROM
ENV INSTALL_XDEBUG=${INSTALL_XDEBUG}
ENV PHP_VERSION=${PHP_VERSION}

RUN if [ ${INSTALL_XDEBUG} = true ]; then \
  # Install the xdebug extension
  # https://xdebug.org/docs/compat
  if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ] || { [ $(php -r "echo PHP_MAJOR_VERSION;") = "7" ] && { [ $(php -r "echo PHP_MINOR_VERSION;") = "4" ] || [ $(php -r "echo PHP_MINOR_VERSION;") = "3" ] ;} ;}; then \
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ]; then \
      pecl install xdebug-3.3.0; \
    else \
      pecl install xdebug-3.1.6; \
    fi; \
  else \
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
      pecl install xdebug-2.5.5; \
    else \
      if [ $(php -r "echo PHP_MINOR_VERSION;") = "0" ]; then \
        pecl install xdebug-2.9.0; \
      else \
        pecl install xdebug-2.9.8; \
      fi \
    fi \
  fi && \
  docker-php-ext-enable xdebug \
;fi

# Copy xdebug configuration for remote debugging
COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

ARG XDEBUG_PORT=9003
ENV XDEBUG_PORT=${XDEBUG_PORT}
RUN if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ] || { [ $(php -r "echo PHP_MAJOR_VERSION;") = "7" ] && { [ $(php -r "echo PHP_MINOR_VERSION;") = "4" ] || [ $(php -r "echo PHP_MINOR_VERSION;") = "3" ] ;} ;}; then \
  sed -i "s/xdebug.remote_host=/xdebug.client_host=/" /usr/local/etc/php/conf.d/xdebug.ini && \
  sed -i "s/xdebug.remote_connect_back=0/xdebug.discover_client_host=true/" /usr/local/etc/php/conf.d/xdebug.ini && \
  sed -i "s/xdebug.remote_port=9000/xdebug.client_port=${XDEBUG_PORT}/" /usr/local/etc/php/conf.d/xdebug.ini && \
  sed -i "s/xdebug.profiler_enable=0/; xdebug.profiler_enable=1/" /usr/local/etc/php/conf.d/xdebug.ini && \
  sed -i "s/xdebug.profiler_output_dir=/xdebug.output_dir=/" /usr/local/etc/php/conf.d/xdebug.ini && \
  sed -i "s/xdebug.remote_mode=req/; xdebug.remote_mode=req/" /usr/local/etc/php/conf.d/xdebug.ini && \
  sed -i "s/xdebug.remote_autostart=0/xdebug.start_with_request=yes/" /usr/local/etc/php/conf.d/xdebug.ini && \
  sed -i "s/xdebug.remote_enable=0/xdebug.mode=debug/" /usr/local/etc/php/conf.d/xdebug.ini \
;else \
  sed -i "s/xdebug.remote_autostart=0/xdebug.remote_autostart=1/" /usr/local/etc/php/conf.d/xdebug.ini && \
  sed -i "s/xdebug.remote_enable=0/xdebug.remote_enable=1/" /usr/local/etc/php/conf.d/xdebug.ini \
;fi
RUN sed -i "s/xdebug.cli_color=0/xdebug.cli_color=1/" /usr/local/etc/php/conf.d/xdebug.ini

###########################################################################
# Install Mailhog:
###########################################################################

RUN apt-get update && apt-get install -y ssmtp \
    && sed -e s/mailhub=mail/mailhub=mailhog:1025/g /etc/ssmtp/ssmtp.conf > ssmtp.conf.tmp \
    && mv ssmtp.conf.tmp /etc/ssmtp/ssmtp.conf \

RUN apt-get update && apt-get install -y curl golang-go \
    && go install github.com/mailhog/mhsendmail@latest \
    && cp /root/go/bin/mhsendmail /usr/bin/mhsendmail \
    && echo 'sendmail_path = /usr/bin/mhsendmail --smtp-addr mailhog_mmem:1025' > /usr/local/etc/php/php.ini

RUN apt-get install -y ssmtp \
    && sed -e s/mailhub=mail/mailhub=mailhog:1025/g /etc/ssmtp/ssmtp.conf > ssmtp.conf.tmp \
    && mv ssmtp.conf.tmp /etc/ssmtp/ssmtp.conf

WORKDIR /var/www/html

CMD ["php-fpm"]

EXPOSE 9000
