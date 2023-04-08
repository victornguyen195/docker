# How to use this docker

### Step1: Go to root directory then clone docker repo

```
git clone git@github.com:victornguyen195/docker.git docker
```
Then cd to docker/

### Step2: Add nginx config file: Ex foodcare.local at docker/nginx/sites
```
upstream fastcgi_backend {
    server php-fpm:9000;
}
server {
    listen 80;
    listen [::]:80;

    server_name fcare.local;
    set $MAGE_ROOT /var/www/html/;
    include /var/www/html/nginx.conf.sample;
    add_header Access-Control-Allow-Origin *;
}

```

### Step3: Config in .env file
Ex: nginx port, workdir, version php, ... 
Then 
```
docker-compose up -d
```

### Step4: Grant permission for data/ and var/ directory
```
sudo chmod 777 -R data/
```
Grant permission for source code **(optional)**
```
find . -name docker -prune -o -type d -exec chmod -R 777 {} \; -o -type f -exec chmod 644 {} \;
```

then try to up container again
```
docker-compose up -d
```

In local you can grant full permission(777) to all file and directories

### Step5: Access to php-fpm container and install package via composer
```
composer i
```

### Step6: Import db
Example
```
docker exec -i docker_percona_1 mysql -uroot -proot fcare < foodcare_stag_20230202.sql
```

### Step7: Setup some basic config

Example
```
bin/magento setup:install --base-url=http://fcare.local:8080/ --db-host=docker_percona_1 --db-name=fcare --db-user=fcare --db-password=fcare --admin-firstname=Victor --admin-lastname="Hoang" --admin-email=admin@admin.com --admin-user=admin --admin-password=admin123 --search-engine=elasticsearch7 --elasticsearch-host=docker_elasticsearch_1 --elasticsearch-port=9200 --backend-frontname=admin

```
### Step8: Config xdebug
```
File -> Settings

Tab: PHP
    PHP Language level: <Choose your php version> Ex: 8.2
    CLI Interpreter: Click ... icon -> Click + icon -> From Docker, Vagrant, VMs, ... -> 
    Configure Remote PHP Interpreter: 
        Choose: Docker-compose
        Server: New -> Unix socket: default unix:///var/run/docker.sock
                Click: OK
        Configuration files: Open and choose docker-composer.yml file
        Service: php-fpm
        Click: OK
    Click: OK
Tab: Servers
    Configure new server:
        Name: <Your server name> Ex: foodcare
        Host: <Your host> Ex: foodcare.local
        Port: 80 with HTTP or 443 with HTTPS
        Click: use path mappings
            <Map root directory with /var/www/html>

Run -> Edit Configurations -> + icon -> PHP Web Page
    Name: <Your name>
    Server: Choose your server you've created. Ex: foodcare
    HTTPS: Click if you want to config HTTPS
    Click: OK
```
