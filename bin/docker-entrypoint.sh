#!/bin/bash

echo 'echo "CONFIG: worker connections: ${NGINX_WORKER_CONNECTIONS:-1024}"' >> /usr/local/bin/initialize.sh
echo 'echo "CONFIG: worker processes: ${NGINX_WORKER_PROCESSES:-1}"' >> /usr/local/bin/initialize.sh

/usr/local/bin/initialize.sh || exit 1

echo "Starting Nginx Web Server ..."

set -e

if [[ "$1" == -* ]]; then
    set -- nginx -g daemon off; "$@"
fi

dockerize -template /etc/nginx/nginx.conf.tmpl:/etc/nginx/nginx.conf

exec "$@"
