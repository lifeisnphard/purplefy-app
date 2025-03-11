FROM cgr.dev/chainguard/php:latest-dev@sha256:aac44eb422870de114940ec864370fb68cdf356ab2827f718f7173dd320eded9 \
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

FROM cgr.dev/chainguard/wordpress:latest-dev@sha256:4d9a8b5b45e221f8bd3f926904c2984e625aaedd47c0574188335527ad1517da \
	AS builder

# Needs any environment variable with name starting with "WORDPRESS_" to trigger wp-config.php creation
ENV WORDPRESS_CONFIG_CREATION=true

USER root

RUN apk update && apk add imagemagick=~7.1.1.40

RUN rm -rf /usr/src/wordpress/wp-content
COPY --from=initial --chown=php:php /app /usr/src/wordpress

USER php

RUN /usr/local/bin/docker-entrypoint.sh php-fpm --version

FROM cgr.dev/chainguard/wordpress:latest@sha256:bc5834a1ede1a25624537e57baf9af5814188882c6abbc0a4b5f8521888f9533 \
	AS final

COPY --from=builder --chown=php:php /var/www/html /var/www/html
