FROM crunchgeek/nginx-pagespeed

LABEL maintainer="Angel Aviel Domaoan <dev.tenshiamd@gmail.com>"

## Installs `dockerize`
RUN apt-get update && apt-get install -y wget
ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

RUN apt-get install -y  software-properties-common
RUN add-apt-repository 'deb http://ftp.debian.org/debian stretch-backports main'
RUN apt-get update && apt-get install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y certbot -t stretch-backports
RUN mkdir -p /var/webroot/letsencrypt/.well-known

## Forwards request and error logs to Docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

WORKDIR /etc/nginx

RUN mkdir -p sites-enabled

## Installs custom configurations
COPY ./conf.d/*.conf conf.d/
ADD snippets snippets
ADD webroot /var/webroot
COPY ./bin/* /usr/local/bin/
RUN cd /usr/local/bin/ && chmod 750 docker-entrypoint.sh
ADD ./nginx.conf.tmpl nginx.conf.tmpl

EXPOSE 80 443

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
