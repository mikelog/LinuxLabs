FROM alpine:3.7

LABEL MAINTAINER="Mikhail Loginov <loginoff.mike@gmail.com>"

RUN apk update
RUN apk add nginx --no-cache
RUN adduser -D -g 'www' www
RUN mkdir /www
RUN chown -R www:www /var/lib/nginx
RUN chown -R www:www /www
RUN mkdir /run/nginx
RUN touch /run/nginx/nginx.pid
RUN chown -R www:www /run/nginx
COPY ./etc/nginx.conf /etc/nginx/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]


