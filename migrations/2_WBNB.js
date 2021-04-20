const json = require('../contracts/TestTokens/WBNB.json');
const contract = require('@truffle/contract');
const WBNB = contract(json);

WBNB.setProvider(this.web3._provider);

module.exports = function(_deployer, network, accounts) {
    _deployer.deploy(WBNB, {from: accounts[0]})
};