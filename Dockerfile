# Add Apache
FROM php:8.1-apache

# Add Library & Dependencies
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
RUN apt-get update && apt-get upgrade -y
