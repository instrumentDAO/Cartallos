const Presale = artifacts.require("Presale");
const CartGovTokenAddress = "0x7907d0C11B358dd1229C9332D85fA22783658bD4";
const PriceRatioOverEthUnitsOfPresale = "500000000000000000"; // .5 eth/bnb/matic per 1 CART purchased

module.exports = function (deployer) {
    deployer.deploy(Presale, CartGovTokenAddress, PriceRatioOverEthUnitsOfPresale);
};

