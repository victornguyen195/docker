ARG PHP_VERSION

FROM php:${PHP_VERSION}-fpm-alpine

RUN apk update && \
   apk add --no-cache mysql-client msmtp perl wget procps shadow libzip libpng libjpeg-turbo libwebp freetype icu icu-data-full bash libxml2-dev libxslt-dev linux-headers vim php-pear autoconf automake libtool patch git

RUN apk add --no-cache --virtual build-essentials \
    icu-dev icu-libs zlib-dev g++ make automake autoconf libzip-dev \
    libwebp-dev libjpeg-turbo-dev freetype-dev && \
    apk cache clean && \
    apk update && \
    apk add --no-cache --virtual libpng-dev-1.6.43-r0 && \
    docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install gd && \
    docker-php-ext-install bcmath && \
    docker-php-ext-install mysqli && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install intl && \
    docker-php-ext-install opcache && \
    docker-php-ext-install exif && \
    docker-php-ext-install zip && \
    docker-php-ext-install xml && \
    docker-php-ext-install soap && \
    docker-php-ext-install sockets && \
    docker-php-ext-install xsl && \
    apk del build-essentials && rm -rf /usr/src/php*

# Update package list and install dependencies
RUN apk update && apk add --no-cache autoconf g++ make

# Install PHP development tools
RUN apk add --no-cache $PHPIZE_DEPS

# Install mailparse extension
RUN pecl install mailparse && docker-php-ext-enable mailparse

# Clean up unnecessary packages
RUN apk del autoconf g++ make

RUN wget https://getcomposer.org/composer-stable.phar -O /usr/local/bin/composer && chmod +x /usr/local/bin/composer

# Add install n98 to run cron
RUN wget https://files.magerun.net/n98-magerun2.phar
RUN chmod +x ./n98-magerun2.phar
RUN cp ./n98-magerun2.phar /usr/local/bin/

###########################################################################
# Install Mailhog:
###########################################################################

RUN apk update && \
    apk add ssmtp && \
    sed -e s/mailhub=mail/mailhub=mailhog:1025/g /etc/ssmtp/ssmtp.conf > ssmtp.conf.tmp && \
    mv ssmtp.conf.tmp /etc/ssmtp/ssmtp.conf


# Define the variable in the Dockerfile
ARG INSTALL_XDEBUG
ARG PHP_VERSION
# Pass the variable to the RUN command using ENV - Required to write after FROM
ENV INSTALL_XDEBUG=${INSTALL_XDEBUG}
ENV PHP_VERSION=${PHP_VERSION}

RUN if [ ${INSTALL_XDEBUG} = true ]; then \
  # Install the xdebug extension
  # https://xdebug.org/docs/compat
  apk add --no-cache --virtual .build-deps $PHPIZE_DEPS && \
  apk add --update linux-headers && \
  if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ] || { [ $(php -r "echo PHP_MAJOR_VERSION;") = "7" ] && { [ $(php -r "echo PHP_MINOR_VERSION;") = "4" ] || [ $(php -r "echo PHP_MINOR_VERSION;") = "3" ] ;} ;}; then \
    # Why change to 8.2.4 ????? Maybe same variable name
    if [ ${PHP_VERSION} = "8.2.4" ] || [ ${PHP_VERSION} = "8.2" ]; then \
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
  docker-php-ext-enable xdebug && \
  apk del -f .build-deps \
;fi


# Copy xdebug configuration for remote debugging
COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini


ARG XDEBUG_PORT=9003
ENV XDEBUG_PORT=${XDEBUG_PORT}
RUN if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ] || { [ $(php -r "echo PHP_MAJOR_VERSION;") = "7" ] && { [ $(php -r "echo PHP_MINOR_VERSION;") = "4" ] || [ $(php -r "echo PHP_MINOR_VERSION;") = "3" ] ;} ;}; then \
  sed -i "s/xdebug.remote_host=/;xdebug.client_host=/" /usr/local/etc/php/conf.d/xdebug.ini && \
    sed -i "s/xdebug.remote_connect_back=0/xdebug.discover_client_host=true/" /usr/local/etc/php/conf.d/xdebug.ini && \
    sed -i "s/xdebug.remote_port=9000/xdebug.client_port=${XDEBUG_PORT}/" /usr/local/etc/php/conf.d/xdebug.ini && \
    sed -i "s/xdebug.profiler_enable=0/; xdebug.profiler_enable=0/" /usr/local/etc/php/conf.d/xdebug.ini && \
    sed -i "s/xdebug.profiler_output_dir=/xdebug.output_dir=/" /usr/local/etc/php/conf.d/xdebug.ini && \
    sed -i "s/xdebug.remote_mode=req/; xdebug.remote_mode=req/" /usr/local/etc/php/conf.d/xdebug.ini && \
    sed -i "s/xdebug.remote_autostart=0/xdebug.start_with_request=yes/" /usr/local/etc/php/conf.d/xdebug.ini && \
    sed -i "s/xdebug.remote_enable=0/xdebug.mode=debug/" /usr/local/etc/php/conf.d/xdebug.ini \
;else \
  sed -i "s/xdebug.remote_autostart=0/xdebug.remote_autostart=1/" /usr/local/etc/php/conf.d/xdebug.ini && \
  sed -i "s/xdebug.remote_enable=0/xdebug.remote_enable=1/" /usr/local/etc/php/conf.d/xdebug.ini \
;fi
RUN sed -i "s/xdebug.cli_color=0/xdebug.cli_color=1/" /usr/local/etc/php/conf.d/xdebug.ini

# Install mailhog
RUN apk update && \
    apk add --no-cache curl go && \
    echo $PATH && \
    go version && \
    go install github.com/mailhog/mhsendmail@latest
RUN cp /root/go/bin/mhsendmail /usr/bin/mhsendmail
RUN echo 'sendmail_path = /usr/bin/mhsendmail --smtp-addr mailhog_mmem:1025' > /usr/local/etc/php/php.ini

RUN apk add ssmtp && \
    sed -e s/mailhub=mail/mailhub=mailhog:1025/g /etc/ssmtp/ssmtp.conf > ssmtp.conf.tmp && \
    mv ssmtp.conf.tmp /etc/ssmtp/ssmtp.conf

WORKDIR /var/www/html

CMD ["php-fpm"]

EXPOSE 9000
