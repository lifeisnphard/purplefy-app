ARG PHP_DEV_TAG=latest-dev
ARG WP_BUILDER_TAG=latest-dev
ARG WP_BASE_TAG=latest

FROM cgr.dev/chainguard/php:${PHP_DEV_TAG} AS initial

USER root

COPY ./wp-content /app/wp-content
COPY ./composer.json ./composer.lock /app/

RUN chown -R php:php /app

USER php

ARG WP_ENV=production
RUN cd /app && if [ "${WP_ENV}" = "production" ]; then \
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
#COPY --from=initial --chown=php:php /app/wp-content /usr/src/wordpress/wp-content
#COPY --from=initial --chown=php:php /app/vendor /usr/src/wordpress/vendor
COPY --from=initial --chown=php:php /app /usr/src/wordpress

USER php

RUN /usr/local/bin/docker-entrypoint.sh php-fpm --version

ARG WP_BASE_TAG
FROM cgr.dev/chainguard/wordpress:${WP_BASE_TAG} AS final

COPY --from=builder --chown=php:php /var/www/html /var/www/html
