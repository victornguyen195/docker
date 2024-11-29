ARG PHP_VERSION

FROM php:${PHP_VERSION}-fpm

# Install required dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    mariadb-client msmtp perl wget procps vim autoconf automake libtool \
    libzip-dev libpng-dev libjpeg-dev libwebp-dev libfreetype6-dev libicu-dev zlib1g-dev \
    libxml2-dev libxslt1-dev linux-headers-amd64 bash && \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install gd bcmath mysqli pdo_mysql intl opcache exif zip xml soap sockets xsl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Download and install PEAR
RUN wget http://pear.php.net/go-pear.phar \
    && php go-pear.phar \
    && rm go-pear.phar

RUN wget https://getcomposer.org/composer-stable.phar -O /usr/local/bin/composer && chmod +x /usr/local/bin/composer

ARG INSTALL_XDEBUG
ARG PHP_VERSION
ENV INSTALL_XDEBUG=${INSTALL_XDEBUG}
ENV PHP_VERSION=${PHP_VERSION}

RUN if [ ${INSTALL_XDEBUG} = true ]; then \
  apt-get update && apt-get install -y $PHPIZE_DEPS linux-headers-amd64 && \
  if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ] || { [ $(php -r "echo PHP_MAJOR_VERSION;") = "7" ] && { [ $(php -r "echo PHP_MINOR_VERSION;") = "4" ] || [ $(php -r "echo PHP_MINOR_VERSION;") = "3" ] ;} ;}; then \
    if [ ${PHP_VERSION} = "8.2.4" ] || [ ${PHP_VERSION} = "8.2" ]  || [ ${PHP_VERSION} = "8.3.4" ]; then \
      pecl install xdebug-3.3.0; \
    else \
      pecl install xdebug-3.1.4; \
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
  apt-get clean && rm -rf /var/lib/apt/lists/* \
;fi

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

# Install mailhog
RUN apt-get update && apt-get install -y curl golang-go && \
    echo $PATH && \
    go version && \
    go install github.com/mailhog/mhsendmail@latest
RUN cp /root/go/bin/mhsendmail /usr/bin/mhsendmail

WORKDIR /var/www/html

CMD ["php-fpm"]

EXPOSE 9000