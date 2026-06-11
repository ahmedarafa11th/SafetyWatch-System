#!/bin/bash
set -e

cd /var/www/safetywatch-api

echo 'Installing composer...'
sudo -u nginx php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo -u nginx php composer-setup.php
sudo -u nginx php composer.phar install --no-dev --optimize-autoloader

echo 'Initializing database...'
sudo -u nginx php artisan key:generate
sudo -u nginx php artisan migrate --force

echo 'Restarting services...'
sudo systemctl restart nginx php-fpm

echo 'DONE!'
