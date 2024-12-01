#!/bin/sh

# Function to reload the crontab
reload_crontab() {
    crontab /etc/cron.d/magento-cron
}

# Initial load of the crontab
reload_crontab

# Start a loop to monitor changes
while true; do
    # Check for changes in the crontab file every minute
    inotifywait -e modify /etc/cron.d/magento-cron
    reload_crontab
done &

# Start the cron daemon
CMD ["exec", "cron", "-f"]

