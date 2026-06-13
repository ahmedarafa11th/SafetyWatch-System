#!/bin/bash
set -e

echo "=== STEP 1: Installing EPEL repo ==="
sudo dnf install -y epel-release

echo "=== STEP 2: Installing Remi repo ==="
sudo dnf install -y https://rpms.remirepo.net/enterprise/remi-release-9.rpm

echo "=== STEP 3: Enabling PHP 8.2 module ==="
sudo dnf module reset php -y
sudo dnf module enable php:remi-8.2 -y

echo "=== STEP 4: Installing PHP and extensions ==="
sudo dnf install -y php php-cli php-fpm php-mbstring php-xml php-curl php-pdo php-gd php-bcmath php-zip php-tokenizer php-process

echo "=== STEP 5: Installing Nginx, Git, SQLite ==="
sudo dnf install -y nginx unzip git sqlite

echo "=== STEP 6: Installing Composer ==="
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

echo "=== STEP 7: Opening firewall ports ==="
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

echo "=== STEP 8: Verifying installations ==="
php -v
composer -V
nginx -v
sqlite3 --version

echo "=== ALL DONE ==="
