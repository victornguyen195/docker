# How to use this docker

### Step1: go to root directory then clone docker repo

```
git clone git@github.com:victornguyen195/docker.git docker
```
Then cd to docker/

### Step2: Config in .env file
Ex: nginx port, workdir, version php, ... 
Then 
```
docker-compose up -d
```

### Step3: Grant permission for data/ and var/ directory
```
sudo chmod 777 -R data/
```
Grant permission for source code (optional)
```
find . -name docker -prune -o -type d -exec chmod -R 777 {} \; -o -type f -exec chmod 644 {} \;
```

then try to up container again
```
docker-compose up -d
```

### Step4: Access to php-fpm container and install package via composer
```
composer i
```

### Step5: Import db
Example
```
docker exec -i docker_percona_1 mysql -uroot -proot fcare < foodcare_stag_20230202.sql
```

### Step6: Setup some basic config

Example
```
bin/magento setup:install --base-url=http://fcare.local:8080/ --db-host=docker_percona_1 --db-name=fcare --db-user=fcare --db-password=fcare --admin-firstname=Victor --admin-lastname="Hoang" --admin-email=admin@admin.com --admin-user=admin --admin-password=admin123 --search-engine=elasticsearch7 --elasticsearch-host=docker_elasticsearch_1 --elasticsearch-port=9201 --backend-frontname=admin

```