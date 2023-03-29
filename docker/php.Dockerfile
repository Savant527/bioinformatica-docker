## Use php 8.1-fpm alpine as parent image
ARG PHP_VERSION=8.2.0-fpm-alpine

## define an alias for the specfic php version used in this file.
FROM php:${PHP_VERSION} as php

# ----------------------
# The FPM base container
# ----------------------
FROM php as php-base-stage

## Retrieve the script used to install PHP extensions from the source container.
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/install-php-extensions

## Install required PHP extensions and all their prerequisites available via apt.
RUN install-php-extensions pdo_pgsql redis

## Setting the work directory.
WORKDIR /app

# ----------------------
# Composer install step
# ----------------------
FROM composer:2.4.2 as dependencies

## Setting the work directory.
WORKDIR /app

# Copy composer files from project root into composer container's working dir
COPY ./src/composer.* ./
COPY ./src/database/ database/

# Run composer to build dependencies in vendor folder
RUN set -xe \
  && composer update \
  --no-dev \
  --no-scripts \
  --no-interaction \
  --prefer-dist \
  --optimize-autoloader \
  --no-plugins

# ----------------------
# The FPM production container
# ----------------------
FROM php-base-stage as php-production-stage

## Setting the work directory.
RUN chown www-data:www-data /app

## Copy everything from project root into php container's working dir
COPY --chown=www-data:www-data ./src /app

## Copy vendor folder from composer container into php container
COPY --from=dependencies --chown=www-data:www-data /app/vendor /app/vendor

USER www-data
