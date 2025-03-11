FROM cgr.dev/chainguard/php:latest-dev@sha256:3d41619837d757d8df4e8554a49395de8aab9ff6e21a9088270d0de0c887812e \
	AS initial

USER root

RUN apk update && apk add subversion

COPY . /app

RUN chown -R php:php /app

USER php

ARG WP_ENV=production
RUN cd /app && if [ "${WP_ENV}" = "production" ]; then \
        composer install --no-dev --no-progress --optimize-autoloader --prefer-dist; \
    else \
        composer install --no-progress --optimize-autoloader --prefer-dist; \
    fi

FROM cgr.dev/chainguard/wordpress:latest-dev@sha256:2234b8d16c5d098ddba6aed6ce4eb379754143a57013ea593aacf7cc24a1f37b \
	AS builder

# Needs any environment variable with name starting with "WORDPRESS_" to trigger wp-config.php creation
ENV WORDPRESS_CONFIG_CREATION=true

USER root

RUN apk update && apk add imagemagick=~7.1.1.40

RUN rm -rf /usr/src/wordpress/wp-content
COPY --from=initial --chown=php:php /app /usr/src/wordpress

USER php

RUN /usr/local/bin/docker-entrypoint.sh php-fpm --version

FROM cgr.dev/chainguard/wordpress:latest@sha256:b2d48e3c35e112f87d80bb5dccb1e892abd18febd36dc0b5ad0cde4e7797cfcd \
	AS final

COPY --from=builder --chown=php:php /var/www/html /var/www/html
