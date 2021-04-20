const Routerjson = require('@uniswap/v2-periphery/build/UniswapV2Router02.json');
const contract = require('@truffle/contract');
const UniswapV2Router02 = contract(Routerjson);

UniswapV2Router02.setProvider(this.web3._provider);

module.exports = function(_deployer, network, accounts ) {
  _deployer.deploy(UniswapV2Router02, "0x9D85A0F7F986013D5cA371CCf35730E77CfA22b2", "0x6DFAFB92fafA78E82802fFA07CCCE1dcD05Ec9de", {from: accounts[0]})
};