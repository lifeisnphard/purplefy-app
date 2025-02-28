ARG COMPOSER_TAG=latest
ARG WP_BUILDER_TAG=latest-dev
ARG WP_BASE_TAG=latest

FROM composer:${COMPOSER_TAG} AS composer

WORKDIR /app

COPY ./wp-content ./wp-content
COPY ./composer.json ./composer.lock ./

ARG WP_ENV=production
RUN if [ "${WP_ENV}" = "production" ]; then \
        composer install --no-dev --optimize-autoloader; \
    else \
        composer install --optimize-autoloader; \
    fi

COPY . .

ARG WP_BUILDER_TAG
FROM cgr.dev/chainguard/wordpress:${WP_BUILDER_TAG} AS builder

# Needs any environment variable with name starting with "WORDPRESS_" to trigger wp-config.php creation
ENV WORDPRESS_CONFIG_CREATION=true

WORKDIR /usr/src/wordpress

COPY --from=composer /app/wp-content ./wp-content
#COPY --from=composer /app/vendor ./vendor

RUN /usr/local/bin/docker-entrypoint.sh php-fpm --version

ARG WP_BASE_TAG
FROM cgr.dev/chainguard/wordpress:${WP_BASE_TAG} AS final

COPY --from=builder --chown=php:php /var/www/html /var/www/html
