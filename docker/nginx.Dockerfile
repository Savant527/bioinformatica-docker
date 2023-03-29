FROM nginx:alpine

WORKDIR /app/public

# COPY ./docker/minimal.nginx.conf /etc/nginx/conf.d/default.conf
COPY ./docker/nginx.conf /etc/nginx/nginx.conf
COPY ./src/public/ /app/public/
