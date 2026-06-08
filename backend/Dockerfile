FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    sqlite3 \
    libsqlite3-dev

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_sqlite mbstring exif pcntl bcmath gd

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

# Ensure the SQLite mount directory is writable
RUN mkdir -p /mnt/sqlite && chown -R www-data:www-data /mnt/sqlite

# Add an explicit entrypoint script to ensure persistent SQLite
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'set -e' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Force the database path to the persistent volume' >> /start.sh && \
    echo 'export DB_DATABASE=/mnt/sqlite/database.sqlite' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Fix permissions on the mounted volume' >> /start.sh && \
    echo 'chown -R www-data:www-data /mnt/sqlite' >> /start.sh && \
    echo 'touch /mnt/sqlite/database.sqlite' >> /start.sh && \
    echo 'chmod 666 /mnt/sqlite/database.sqlite' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Create a symlink so any code using the default path also hits the volume' >> /start.sh && \
    echo 'rm -f /var/www/database/database.sqlite' >> /start.sh && \
    echo 'ln -sf /mnt/sqlite/database.sqlite /var/www/database/database.sqlite' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Remove any cached config that might have stale paths' >> /start.sh && \
    echo 'rm -f /var/www/bootstrap/cache/config.php' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Run migrations (will not re-run already-applied ones)' >> /start.sh && \
    echo 'php artisan migrate --force' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Only seed if users table is empty (first boot)' >> /start.sh && \
    echo 'USER_COUNT=$(php artisan tinker --execute="echo \\App\\Models\\User::count();" 2>/dev/null | tr -d "[:space:]")' >> /start.sh && \
    echo 'if [ "$USER_COUNT" = "0" ] || [ -z "$USER_COUNT" ]; then' >> /start.sh && \
    echo '  php artisan db:seed --force' >> /start.sh && \
    echo 'fi' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Start the server' >> /start.sh && \
    echo 'php artisan serve --host=0.0.0.0 --port=8000' >> /start.sh && \
    chmod +x /start.sh

# Run the app
CMD ["/start.sh"]
