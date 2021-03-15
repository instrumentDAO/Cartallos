const Migrations = artifacts.require("Migrations");
const DiversifyGeneral = artifacts.require("DiversifyGeneral");
const DiversifyPures = artifacts.require("DiversifyPures");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(DiversifyGeneral);
  deployer.deploy(DiversifyPures);
};
