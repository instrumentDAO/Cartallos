const Migrations = artifacts.require("Migrations");
const CartallosGeneral = artifacts.require("CartallosGeneral");
const CartallosPures = artifacts.require("CartallosPures");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(CartallosGeneral);
  deployer.deploy(CartallosPures);
};
