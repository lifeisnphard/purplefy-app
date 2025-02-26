FROM bitnami/wordpress-nginx:${WP_IMAGE_TAG}

WORKDIR /bitnami/wordpress

COPY ./wp-content ./wp-content/
COPY ./composer.json ./composer.lock ./

USER root

RUN if [ "$WP_ENV" = "production" ]; then \
        composer install --no-dev --optimize-autoloader; \
    else \
        composer install --optimize-autoloader; \
    fi

RUN chown -R daemon:daemon .

RUN rm -rf /opt/bitnami/wordpress/wp-content

RUN ln -s /bitnami/wordpress/wp-content /opt/bitnami/wordpress/wp-content

RUN chown -R daemon:daemon /opt/bitnami/wordpress/wp-content

USER daemon