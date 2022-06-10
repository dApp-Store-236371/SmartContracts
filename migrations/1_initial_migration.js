const Migrations = artifacts.require("Migrations");
const DAppStore = artifacts.require("dAppStore");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(DAppStore);
};
