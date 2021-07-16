FROM node:14
WORKDIR /contracts
COPY . .
RUN npm install truffle -g
RUN npm install -g ganache-cli
RUN npm install @openzeppelin/contracts
EXPOSE 8545