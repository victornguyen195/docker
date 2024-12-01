ARG CONTAINER_PHP_NAME

FROM ${CONTAINER_PHP_NAME}

# php extensions to run Magento
RUN apt-get update && apt-get install -y cron

# Cron
COPY ./crontab /etc/cron.d/magento-cron
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN groupadd -g 1000 cronuser && useradd -u 1000 -g cronuser cronuser
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Install n98
#RUN wget https://files.magerun.net/n98-magerun2.phar && mv n98-magerun2.phar /var/www/html/n98-magerun2.phar
RUN wget https://files.magerun.net/n98-magerun2.phar
RUN chmod +x /var/www/html/n98-magerun2.phar

WORKDIR /var/www/html
