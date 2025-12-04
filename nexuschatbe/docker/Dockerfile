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
    supervisor \
    default-mysql-client \
    gnupg

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions required by Laravel
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy application code
COPY . /var/www

# Copy supervisor config and entrypoint
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh

# Make entrypoint executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Create storage directories and set permissions
RUN mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views storage/logs \
    && chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Create .env if it doesn't exist (will be overwritten by volume/copy)
RUN if [ ! -f .env ]; then cp .env.example .env 2>/dev/null || echo "APP_KEY=" > .env; fi

# Optimize Laravel (skip key:generate as it will be done later)
RUN php artisan config:cache || true
RUN php artisan route:cache || true  
RUN php artisan view:cache || true

# Expose port 9000
EXPOSE 9000

# Use entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]