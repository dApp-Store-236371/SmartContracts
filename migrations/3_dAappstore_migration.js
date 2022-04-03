let dAppstore = artifacts.require("./dAppstore.sol");

module.exports = function (deployer) {
  deployer.deploy(dAppstore);
};
