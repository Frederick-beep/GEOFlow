FROM php:8.4-cli-bookworm

WORKDIR /var/www/html

# Install system deps + dev tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git libicu-dev libzip-dev unzip postgresql-client \
    libpng-dev libjpeg-dev libfreetype6-dev libonig-dev \
    && rm -rf /var/lib/apt/lists/*

# PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd mbstring pdo_pgsql pdo_sqlite pcntl zip

# Redis extension
RUN pecl install redis && docker-php-ext-enable redis

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_MEMORY_LIMIT=-1 \
    COMPOSER_PROCESS_TIMEOUT=2000

# Speed up composer in China
RUN composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

# Vite / Node for assets build
RUN apt-get update && apt-get install -y nodejs npm && rm -rf /var/lib/apt/lists/*

# Port
ENV APP_PORT=18080
EXPOSE 18080