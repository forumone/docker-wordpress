ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm-alpine AS base

COPY --from=forumone/f1-ext-install:latest \
  /f1-ext-install \
  /usr/local/bin/f1-ext-install

RUN set -ex \
  && f1-ext-install \
    builtin:bcmath \
    builtin:exif \
    builtin:gd \
    builtin:mysqli \
    builtin:opcache \
    builtin:zip \
    pecl:imagick \
  # Settings taken from library's WordPress image
  && { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
  } > /usr/local/etc/php/conf.d/opcache-recommended.ini \
  && { \
    echo 'error_reporting = E_ERROR | E_WARNING | E_PARSE | E_CORE_ERROR | E_CORE_WARNING | E_COMPILE_ERROR | E_COMPILE_WARNING | E_RECOVERABLE_ERROR'; \
    echo 'display_errors = Off'; \
    echo 'display_startup_errors = Off'; \
    echo 'log_errors = On'; \
    echo 'error_log = /dev/stderr'; \
    echo 'log_errors_max_len = 1024'; \
    echo 'ignore_repeated_errors = On'; \
    echo 'ignore_repeated_source = Off'; \
    echo 'html_errors = Off'; \
  } > /usr/local/etc/php/conf.d/error-logging.ini

WORKDIR /var/www/html

FROM base AS xdebug

ARG XDEBUG_VERSION=stable
RUN f1-ext-install pecl:xdebug@${XDEBUG_VERSION}
