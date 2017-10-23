FROM node:latest

RUN mkdir -p /usr/lottery/deployer

WORKDIR /usr/lottery/deployer

COPY package.json /usr/lottery/deployer

RUN npm install

COPY . /usr/lottery/deployer

ENV TRUFFLE_NETWORK=docker

CMD ["truffle", "exec", " index.js"]
