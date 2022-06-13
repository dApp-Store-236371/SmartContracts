const Migrations = artifacts.require("Migrations");
const Constants = artifacts.require("Constants");
const Events = artifacts.require("Events");
const StringUtils = artifacts.require("StringUtils");
const AddressUtils = artifacts.require("AddressUtils");
const AddressPayableUtils = artifacts.require("AddressPayableUtils");
const AppInfoLibrary = artifacts.require("AppInfoLibrary");
const App = artifacts.require("App");
const User = artifacts.require("User");
const dAppstore = artifacts.require("dAppstore");


module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(Constants);
  deployer.deploy(Events);
  deployer.deploy(StringUtils);
  deployer.deploy(AddressUtils);
  deployer.deploy(AddressPayableUtils);
  deployer.deploy(AppInfoLibrary);
  deployer.link(Constants, [App, User, dAppstore]);
  deployer.link(Events, [App, User, dAppstore]);
  deployer.link(StringUtils, [App, User, dAppstore]);
  deployer.link(AddressUtils, [App, User, dAppstore]);
  deployer.link(AddressPayableUtils, [App, User, dAppstore]);
  deployer.link(AppInfoLibrary, [App, User, dAppstore]);
  deployer.deploy(dAppstore);
};
