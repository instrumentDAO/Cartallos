const ETH = artifacts.require("ETH");
const BTC = artifacts.require("BTC");

module.exports = function (deployer) {
  deployer.deploy(ETH);
  deployer.deploy(BTC);
};


