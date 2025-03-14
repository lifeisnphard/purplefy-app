FROM cgr.dev/chainguard/php:latest-dev@sha256:3d41619837d757d8df4e8554a49395de8aab9ff6e21a9088270d0de0c887812e \
	AS base

USER root

RUN apk update && apk add subversion

COPY . /app

RUN chown -R php:php /app

USER php

ARG COMPOSER_ADDITIONAL_ARGS="--no-dev"
RUN cd /app && \
    composer install --no-interaction --no-progress --optimize-autoloader --prefer-dist ${COMPOSER_ADDITIONAL_ARGS}

FROM cgr.dev/chainguard/wordpress:latest-dev@sha256:4d9a8b5b45e221f8bd3f926904c2984e625aaedd47c0574188335527ad1517da \
	AS dev

# Needs any environment variable with name starting with "WORDPRESS_" to trigger wp-config.php creation
ENV WORDPRESS_CONFIG_CREATION=true

USER root

RUN apk update && apk add imagemagick=~7.1.1.40

RUN rm -rf /usr/src/wordpress/wp-content
COPY --from=base --chown=php:php --chmod=775 /app /usr/src/wordpress

USER php

RUN /usr/local/bin/docker-entrypoint.sh php-fpm --version

FROM cgr.dev/chainguard/wordpress:latest@sha256:bc5834a1ede1a25624537e57baf9af5814188882c6abbc0a4b5f8521888f9533 \
	AS prod

COPY --from=dev --chown=php:php /var/www/html /var/www/html
