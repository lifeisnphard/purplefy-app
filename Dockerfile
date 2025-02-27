ARG WP_IMAGE_TAG
FROM bitnami/wordpress-nginx:${WP_IMAGE_TAG}

WORKDIR /opt/bitnami/wordpress

RUN rm -rf ./wp-content
COPY ./wp-content ./wp-content
COPY ./composer.json ./composer.lock ./

USER root

ARG WP_ENV
RUN if [ "$WP_ENV" = "production" ]; then \
        composer install --no-dev --optimize-autoloader; \
    else \
        composer install --optimize-autoloader; \
    fi

RUN chown -R daemon:daemon ./wp-content

RUN sed -i -e 's/^listen.owner = root/listen.owner = daemon/' \
           -e 's/^listen.group = root/listen.group = daemon/' \
           /opt/bitnami/php/etc/php-fpm.d/www.conf

WORKDIR /bitnami/wordpress

EXPOSE 8080 8443

USER daemon
ENTRYPOINT [ "/opt/bitnami/scripts/wordpress/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/nginx-php-fpm/run.sh" ]
