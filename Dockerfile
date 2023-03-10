# используем официальный образ PHP-FPM в качестве базового образа
FROM php:8.0-fpm

# устанавливаем дополнительные пакеты
RUN apt-get update && \
    apt-get install -y \
        git \
        libzip-dev \
        unzip \
        libicu-dev \
        libonig-dev \
        libpq-dev \
        nginx

# устанавливаем расширения PHP
RUN docker-php-ext-install \
    pdo \
    pdo_pgsql \
    pgsql \
    zip \
    intl \
    mbstring \
    exif \
    pcntl \
    bcmath

# устанавливаем composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# копируем конфигурационный файл nginx
COPY nginx.conf /etc/nginx/nginx.conf

# копируем проект Laravel в Docker-контейнер
COPY . /var/www/html

# переключаемся в директорию проекта Laravel
WORKDIR /var/www/html

# устанавливаем зависимости проекта Laravel с помощью composer
RUN composer install --no-scripts --no-autoloader

# генерируем ключ для приложения Laravel
RUN php artisan key:generate

# задаем права на директории для хранения кэша и сессий
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# экспонируем порт 80
EXPOSE 80

# запускаем nginx и php-fpm
CMD service nginx start && php-fpm
