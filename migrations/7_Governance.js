const CART = artifacts.require("Cartallos");
const CARTController = '0x3e6E59c45c65F4Da3be7fB8bf67eef54B84B287b';

module.exports = function (deployer) {
  deployer.deploy(CART, CARTController);
};

