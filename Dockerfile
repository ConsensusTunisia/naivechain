FROM node:alpine

RUN mkdir /naivechain
ADD package.json /naivechain/
RUN cd /naivechain && npm install

ADD main.js /naivechain/
ADD index.html /naivechain/

EXPOSE 3001
EXPOSE 6001

ENTRYPOINT cd /naivechain && npm install && PEERS=$PEERS npm start
