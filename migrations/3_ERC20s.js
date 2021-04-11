const ETH = artifacts.require("ETH");
const BTC = artifacts.require("BTC");
const Wbnb = artifacts.require("WBNB")

module.exports = function (deployer) {
  deployer.deploy(ETH);
  deployer.deploy(BTC);
  deployer.deploy(Wbnb);
};


