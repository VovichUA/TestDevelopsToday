FROM node:16.7.0

RUN npm config set registry https://registry.npmjs.org && \
    npm install -g agentkeepalive npm@8.1.2

RUN apt-get update && apt-get install \
    git \
    autoconf

WORKDIR /var/www/app
