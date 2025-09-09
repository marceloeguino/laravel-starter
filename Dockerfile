# -----------------------------
# Stage 1: Builder
# -----------------------------
FROM php:8.2-cli AS builder

# Instalar extensiones necesarias
RUN apt-get update && apt-get install -y \
    git unzip curl libzip-dev \
    && docker-php-ext-install zip

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Copiar archivos de composer para cache
COPY composer.json composer.lock ./

# Instalar dependencias sin scripts (evita error artisan)
RUN composer install --no-dev --no-interaction --optimize-autoloader --no-scripts

# Copiar todo el código
COPY . .

# Ejecutar package discover después de copiar artisan
RUN php artisan package:discover --ansi


# -----------------------------
# Stage 2: Runtime
# -----------------------------
FROM php:8.2-fpm-alpine AS runtime

# Crear usuario no-root
RUN addgroup -g 1000 appuser && adduser -D -G appuser -u 1000 appuser

# Instalar nginx y curl
RUN apk add --no-cache nginx curl

# Crear directorios necesarios
RUN mkdir -p /var/www/html/public \
    && mkdir -p /home/appuser/nginx/tmp/client_body \
               /home/appuser/nginx/tmp/proxy \
               /home/appuser/nginx/tmp/fastcgi \
               /home/appuser/nginx/tmp/uwsgi \
               /home/appuser/nginx/tmp/scgi \
               /home/appuser/nginx/logs \
    && chown -R appuser:appuser /var/www/html /home/appuser/nginx

WORKDIR /var/www/html

# Copiar app desde builder
COPY --from=builder --chown=appuser:appuser /app /var/www/html

# Copiar configuración mínima de nginx
RUN mkdir -p /etc/nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Cambiar a usuario no-root
USER appuser

# Exponer puerto
EXPOSE 80

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s CMD curl -f http://localhost/api/hello || exit 1

# CMD para iniciar php-fpm y nginx en primer plano
CMD ["sh", "-c", "php-fpm -D && nginx -c /etc/nginx/nginx.conf -g 'daemon off;'"]