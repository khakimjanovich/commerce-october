FROM php:7.2.9-fpm

ARG user
ARG uid

RUN mkdir /var/www/html/app
# Copy composer.lock and composer.json
COPY composer.json /var/www/html/app/

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    unzip


# Install ext-zip
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    && docker-php-ext-install zip

# Install intl extension
RUN apt-get -y update \
&& apt-get install -y libicu-dev \
&& docker-php-ext-configure intl \
&& docker-php-ext-install intl

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www/html/app

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd
# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer

# Copy existing application directory contents
COPY . /var/www/html/app

# Copy existing application directory permissions
USER root

RUN chown -R www-data:www-data /var/www/html/app && chmod -R 775 /var/www/html/app

# Give permissions to edit logs and storage
RUN chmod -R 777 /var/www/html/app/storage && chmod -R 777 /var/www/html/app/storage/logs

COPY --chown=www:www . /var/www/html/app

# Change current user to www
USER $user

# Expose port 9001 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
