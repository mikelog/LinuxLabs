FROM alpine:3.7

LABEL MAINTAINER="Mikhail Loginov <loginoff.mike@gmail.com>"

RUN apk --update --no-cache add php7 php7-bcmath php7-dom php7-ctype php7-curl php7-fpm  php7-gd  php7-iconv php7-intl  php7-json php7-mbstring  php7-mcrypt  php7-mysqlnd  php7-opcache php7-openssl  php7-pdo  php7-pdo_mysql  php7-phar php7-posix php7-session  php7-soap  php7-xml php7-zip 
CMD  mkdir /www 
WORKDIR /www
RUN adduser -D -g 'www-data' www-data
COPY ./etc/www.conf /etc/php7/php-fpm.d/
COPY ./index.php /www/
EXPOSE 9000
CMD ["php-fpm7", "-F"]


