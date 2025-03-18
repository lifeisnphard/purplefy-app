FROM cgr.dev/chainguard/php:latest-dev@sha256:3d41619837d757d8df4e8554a49395de8aab9ff6e21a9088270d0de0c887812e \
	AS base

USER root

# Install required system dependencies
RUN apk update && apk add --no-cache subversion

# Copy application files
COPY --chown=php:php . /app

USER php

# Changes the working directory to /app
WORKDIR /app

# Development PHP dependencies stage
FROM base AS php-dev

RUN composer install --no-interaction --no-progress --optimize-autoloader --prefer-dist

# Production PHP dependencies stage
FROM base AS php-prod

RUN composer install --no-dev --no-interaction --no-progress --optimize-autoloader --prefer-dist

# WordPress base stage
FROM cgr.dev/chainguard/wordpress:latest-dev@sha256:4d9a8b5b45e221f8bd3f926904c2984e625aaedd47c0574188335527ad1517da \
	AS wp-base

# Needs any environment variable with name starting with "WORDPRESS_" to trigger wp-config.php creation
ENV WORDPRESS_CONFIG_CREATION=true

USER root

RUN apk update && apk add --no-cache imagemagick=~7.1.1.40

# Remove default wp-content to be replaced by our custom one
RUN rm -rf /usr/src/wordpress/wp-content

# Development WordPress stage
FROM wp-base AS wp-dev

# Copy PHP dependencies and application files from php-dev stage
COPY --from=php-dev --chown=php:php --chmod=775 /app /usr/src/wordpress

USER php

# Verify PHP-FPM is working
RUN /usr/local/bin/docker-entrypoint.sh php-fpm --version

# Debug WordPress stage
FROM wp-dev AS wp-debug

# Enable WordPress debugging
ENV WORDPRESS_DEBUG=true

# Verify wp-cli is working
# TODO: Recheck this logic since this requires wp-cli to be included in Composer dependencies
RUN /var/www/html/wp-content/vendor/bin/wp --info

# Production build stage
FROM wp-base AS build

# Copy PHP dependencies and application files from php-prod stage
COPY --from=php-prod --chown=php:php --chmod=775 /app /usr/src/wordpress

USER php

# Verify PHP-FPM is working
RUN /usr/local/bin/docker-entrypoint.sh php-fpm --version

# Production WordPress stage
FROM cgr.dev/chainguard/wordpress:latest@sha256:bc5834a1ede1a25624537e57baf9af5814188882c6abbc0a4b5f8521888f9533 \
	AS wp-prod

# Copy built application from the build stage
COPY --from=build --chown=php:php /var/www/html /var/www/html
