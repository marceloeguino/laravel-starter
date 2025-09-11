# -----------------------------
# Stage 1: Builder
# -----------------------------
FROM php:8.2-cli AS builder

# Install required extensions and tools
RUN apt-get update && apt-get install -y \
    git unzip curl libzip-dev \
    && docker-php-ext-install zip \
    && rm -rf /var/lib/apt/lists/*

# Install Composer (PHP dependency manager)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Copy composer files for dependency caching
COPY composer.json composer.lock ./

# Install PHP dependencies without dev packages or scripts, then clean composer cache
RUN composer install --no-dev --no-interaction --optimize-autoloader --no-scripts \
    && rm -rf /root/.composer

# Copy the rest of the application code
COPY . .

# Run Laravel package discovery (required after copying artisan)
RUN php artisan package:discover --ansi

# -----------------------------
# Stage 2: Runtime
# -----------------------------
FROM php:8.2-fpm-alpine AS runtime

# Create a non-root user for security
RUN addgroup -g 1000 appuser && adduser -D -G appuser -u 1000 appuser

# Install nginx and curl
RUN apk add --no-cache nginx curl

# Create necessary directories for the app and nginx, set ownership
RUN mkdir -p /var/www/html/public \
    && mkdir -p /var/lib/nginx/logs \
    && chown -R appuser:appuser /var/www/html /home/appuser/nginx /var/lib/nginx \
    && mkdir -p /etc/nginx

WORKDIR /var/www/html

# Copy built application from builder stage, set ownership to appuser
COPY --from=builder --chown=appuser:appuser /app /var/www/html

# Copy minimal nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Switch to non-root user
USER appuser

# Expose HTTP port
EXPOSE 80

# Define healthcheck for Docker (checks Laravel endpoint)
HEALTHCHECK --interval=30s --timeout=5s CMD curl -f http://localhost/api/hello || exit 1

# Start php-fpm and nginx in the foreground
CMD ["sh", "-c", "php-fpm -D && nginx -c /etc/nginx/nginx.conf -g 'daemon off;'"]
