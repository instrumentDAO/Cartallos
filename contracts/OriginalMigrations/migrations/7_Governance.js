const CART = artifacts.require("Cartallos");
const CARTController = '0x6a2B6283AD99b412b717564c068Ab8Bd97294AC4';

module.exports = function (deployer) {
  deployer.deploy(CART, CARTController);
};

