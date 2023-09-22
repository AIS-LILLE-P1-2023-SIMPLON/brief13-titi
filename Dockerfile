FROM php:7.4-apache
WORKDIR /var/www/html
# update packages
RUN apt-get update
# install zip and pdo extensions
RUN apt-get install -y \
        libzip-dev \
        zip \
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip \
    && docker-php-ext-install pdo pdo_mysql

# install gd image library
RUN apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j "$(nproc)" gd

# install intl extension
RUN apt-get install -y zlib1g-dev libicu-dev g++ \
&& docker-php-ext-configure intl \
&& docker-php-ext-install intl

# enable mod_rewrite
RUN a2enmod rewrite

# install opcache for php acceleration
RUN docker-php-ext-install opcache \
    && docker-php-ext-enable opcache \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoremove -y

# install database
RUN apt-get update
RUN apt-get install -y mariadb-server

# create user-psuser password-admin and assign privileges
RUN service mariadb start && mysql -uroot mysql -e "CREATE USER 'tristan'@localhost IDENTIFIED BY 'Ryugen66'; GRANT ALL PRIVILEGES ON *.* TO 'tristan'@localhost IDENTIFIED BY 'Ryugen66';FLUSH PRIVILE>

# copy prestashop folder content
COPY /home/user/prestashop /var/www/html
# Change owner and permissions
# RUN chown -R www-data:www-data /var/www/html/var/logs
RUN chmod -R 645 /var/www/html/var/logs \
/var/www/html/var/cache \
/var/www/html/config \
/var/www/html/img \
/var/www/html/mails \
/var/www/html/modules \
/var/www/html/translations \
/var/www/html/upload \
/var/www/html/download \
/var/www/html/app/config \
/var/www/html/app/Resources/translations \
/var/www/html/img

RUN touch /usr/local/etc/php/php.ini && echo "short_open_tag=FALSE" >> /usr/local/etc/php/php.ini

EXPOSE 80
