FROM alpine:3.18.3 as release

RUN apk --no-cache add ca-certificates \
  && apk --no-cache add \
    curl \
    tar

RUN mkdir /source
WORKDIR /source
RUN curl -Lo strichliste.tar.gz https://github.com/strichliste/strichliste/releases/download/v1.8.2/strichliste-v1.8.2.tar.gz
RUN tar -xf strichliste.tar.gz
RUN rm -r strichliste.tar.gz


FROM alpine:3.18.3

RUN apk --no-cache add ca-certificates \
  && apk --no-cache add \
    curl \
    php81 \
    php81-ctype \
    php81-tokenizer \
    php81-iconv \
    php81-mbstring \
    php81-xml \
    php81-json \
    php81-dom \
    php81-pdo_mysql \
    php81-fpm \
    php81-session \
    nginx \
    bash \
    mysql-client \
    yarn

COPY --from=release /source source

COPY entrypoint.sh /source/entrypoint.sh
RUN chmod +x /source/entrypoint.sh

RUN adduser -u 82 -D -S -G www-data www-data
RUN chown -R www-data:www-data /source
RUN chown -R www-data:www-data /var/lib/nginx
RUN chown -R www-data:www-data /var/log/nginx
RUN chown -R www-data:www-data /var/log/php81

USER www-data

COPY ./config/php-fpm.conf /etc/php81/php-fpm.conf
COPY ./config/www.conf /etc/php81/php-fpm.d/www.conf
COPY ./config/nginx.conf /etc/nginx/nginx.conf
COPY ./config/default.conf /etc/nginx/conf.d/default.conf

VOLUME /source/var

WORKDIR /source/public
EXPOSE 8080

ENTRYPOINT ["/source/entrypoint.sh"]
CMD nginx && php-fpm81
