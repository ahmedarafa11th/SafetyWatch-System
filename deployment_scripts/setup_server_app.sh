#!/bin/bash
set -e

echo 'Cloning repository...'
sudo rm -rf /tmp/safetywatch-repo
sudo git clone https://github.com/ahmedarafa11th/SafetyWatch-System.git /tmp/safetywatch-repo

echo 'Setting up web directory...'
sudo mkdir -p /var/www/safetywatch-api
sudo cp -r /tmp/safetywatch-repo/SafetyWatch-Backend/. /var/www/safetywatch-api/
sudo chown -R nginx:nginx /var/www/safetywatch-api

cd /var/www/safetywatch-api

echo 'Installing composer...'
sudo -u nginx php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo -u nginx php composer-setup.php
sudo -u nginx php composer.phar install --no-dev --optimize-autoloader

echo 'Setting up environment variables...'
sudo -u nginx cp .env.example .env
sudo sed -i 's/DB_CONNECTION=mysql/DB_CONNECTION=sqlite/g' .env
sudo sed -i 's/DB_HOST=127.0.0.1/#DB_HOST=127.0.0.1/g' .env
sudo sed -i 's/DB_PORT=3306/#DB_PORT=3306/g' .env
sudo sed -i 's/DB_DATABASE=laravel/#DB_DATABASE=laravel/g' .env
sudo sed -i 's/DB_USERNAME=root/#DB_USERNAME=root/g' .env
sudo sed -i 's/DB_PASSWORD=/#DB_PASSWORD=/g' .env

echo 'Initializing database...'
sudo -u nginx touch database/database.sqlite
sudo -u nginx php artisan key:generate
sudo -u nginx php artisan migrate --force

echo 'Setting up Nginx configuration...'
cat << 'NGINX' | sudo tee /etc/nginx/conf.d/safetywatch.conf
server {
    listen 80;
    server_name 141.144.238.112;
    root /var/www/safetywatch-api/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/run/php-fpm/www.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
NGINX

echo 'Configuring SELinux...'
sudo setsebool -P httpd_can_network_connect 1 || true
sudo chcon -Rt httpd_sys_content_t /var/www/safetywatch-api || true
sudo chcon -Rt httpd_sys_rw_content_t /var/www/safetywatch-api/storage || true
sudo chcon -Rt httpd_sys_rw_content_t /var/www/safetywatch-api/bootstrap/cache || true
sudo chcon -Rt httpd_sys_rw_content_t /var/www/safetywatch-api/database || true

echo 'Restarting services...'
sudo systemctl restart nginx php-fpm

echo 'DONE!'
