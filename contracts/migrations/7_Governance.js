const CART = artifacts.require("Cartallos");
const CARTController = '0x93cC95b441b02c7E65d52018F1f7c8DfBdfDA03b';

module.exports = function (deployer) {
  deployer.deploy(CART, CARTController);
};

