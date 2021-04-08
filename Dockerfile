FROM node:14
WORKDIR /contracts
RUN npm install truffle -g
RUN npm install -g ganache-cli
RUN npm install @openzeppelin/contracts
COPY . .
EXPOSE 8545