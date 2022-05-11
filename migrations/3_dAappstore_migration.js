let dAppstore = artifacts.require("./dAppstore_v1.sol");

module.exports = function (deployer) {
  deployer.deploy(dAppstore);
};
