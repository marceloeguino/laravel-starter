#!/bin/sh
set -e

# Replace values in .env file with runtime env vars
[ -n "${APP_ENV}" ] && sed -i "s/^APP_ENV=.*/APP_ENV=${APP_ENV}/" /var/www/html/.env
[ -n "${APP_KEY}" ] && sed -i "s/^APP_KEY=.*/APP_KEY=${APP_KEY}/" /var/www/html/.env
[ -n "${APP_URL}" ] && sed -i "s|^APP_URL=.*|APP_URL=${APP_URL}|" /var/www/html/.env

# Clear and cache config
php artisan config:clear
php artisan cache:clear

# Run php-fpm and nginx
exec "$@"
