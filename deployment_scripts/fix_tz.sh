sudo sed -i "s/'timezone' => 'UTC'/'timezone' => 'Africa\/Cairo'/g" /var/www/safetywatch-api/config/app.php && sudo php /var/www/safetywatch-api/artisan config:clear
