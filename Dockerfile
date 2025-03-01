ARG COMPOSER_TAG=latest
ARG WP_BUILDER_TAG=latest-dev
ARG WP_BASE_TAG=latest

FROM composer:${COMPOSER_TAG} AS initial

WORKDIR /app

COPY ./wp-content ./wp-content
COPY ./composer.json ./composer.lock ./

ARG WP_ENV=production
RUN if [ "${WP_ENV}" = "production" ]; then \
        composer install --no-dev --no-progress --optimize-autoloader --prefer-dist; \
    else \
        composer install --no-progress --optimize-autoloader --prefer-dist; \
    fi

ARG WP_BUILDER_TAG
FROM cgr.dev/chainguard/wordpress:${WP_BUILDER_TAG} AS builder

# Needs any environment variable with name starting with "WORDPRESS_" to trigger wp-config.php creation
ENV WORDPRESS_CONFIG_CREATION=true

USER root

RUN apk update && apk add imagemagick=~7.1.1.40

RUN rm -rf /usr/src/wordpress/wp-content
COPY --from=initial --chown=php:php /app/wp-content /usr/src/wordpress/wp-content
#COPY --from=initial --chown=php:php /app/vendor /usr/src/wordpress/vendor

USER php

RUN /usr/local/bin/docker-entrypoint.sh php-fpm --version

ARG WP_BASE_TAG
FROM cgr.dev/chainguard/wordpress:${WP_BASE_TAG} AS final

COPY --from=builder --chown=php:php /var/www/html /var/www/html
