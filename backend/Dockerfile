FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    zip \
    unzip \
    sqlite3 \
    libsqlite3-dev \
    nginx

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions (both SQLite and PostgreSQL for flexibility)
RUN docker-php-ext-install pdo_sqlite pdo_pgsql pgsql mbstring exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy existing application directory contents
COPY . /var/www

# Install laravel dependencies
RUN composer install --optimize-autoloader --no-dev

# Set permissions
RUN chown -R www-data:www-data /var/www \
    && chmod -R 775 /var/www/storage \
    && chmod -R 775 /var/www/bootstrap/cache

# Configure Nginx for Render
RUN echo 'server {\n\
    listen 8000;\n\
    root /var/www/public;\n\
    index index.php;\n\
    \n\
    add_header Access-Control-Allow-Origin "*" always;\n\
    add_header Access-Control-Allow-Methods "GET, POST, PUT, PATCH, DELETE, OPTIONS" always;\n\
    add_header Access-Control-Allow-Headers "Authorization, Content-Type, Accept, X-Requested-With" always;\n\
    \n\
    if ($request_method = "OPTIONS") {\n\
        return 204;\n\
    }\n\
    \n\
    location / {\n\
        try_files $uri $uri/ /index.php?$query_string;\n\
    }\n\
    \n\
    location ~ \\.php$ {\n\
        fastcgi_pass 127.0.0.1:9000;\n\
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;\n\
        include fastcgi_params;\n\
    }\n\
    \n\
    client_max_body_size 10M;\n\
}' > /etc/nginx/sites-available/default

# Create entrypoint script
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'set -e' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Remove any cached config' >> /start.sh && \
    echo 'rm -f /var/www/bootstrap/cache/config.php' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Run migrations' >> /start.sh && \
    echo 'php artisan migrate --force' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Only seed if users table is empty (first boot)' >> /start.sh && \
    echo 'USER_COUNT=$(php artisan tinker --execute="echo \\App\\Models\\User::count();" 2>/dev/null | tr -d "[:space:]")' >> /start.sh && \
    echo 'if [ "$USER_COUNT" = "0" ] || [ -z "$USER_COUNT" ]; then' >> /start.sh && \
    echo '  php artisan db:seed --force' >> /start.sh && \
    echo 'fi' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Start PHP-FPM in the background' >> /start.sh && \
    echo 'php-fpm -D' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Start Nginx in foreground' >> /start.sh && \
    echo 'nginx -g "daemon off;"' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 8000

CMD ["/start.sh"]
