const Uniswapv2Factory = artifacts.require("Uniswapv2Factory");
const PancakeRouter = artifacts.require("PancakeRouter");

module.exports = function (deployer) {
  deployer.deploy(Uniswapv2Factory, '0x6a2B6283AD99b412b717564c068Ab8Bd97294AC4').then(function(){
    deployer.deploy(PancakeRouter, Uniswapv2Factory.address);
  });

};
