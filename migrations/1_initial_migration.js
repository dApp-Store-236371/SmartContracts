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
const AppManager = artifacts.require("./Apps/AppManager");
const UserManager = artifacts.require("./Users/UserManager");


module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(Constants);
  deployer.deploy(Events);
  deployer.deploy(StringUtils);
  deployer.deploy(AddressUtils);
  deployer.deploy(AddressPayableUtils);
  deployer.deploy(AppInfoLibrary);
  deployer.link(Constants, [App, User,AppManager, UserManager, dAppstore]);
  deployer.link(Events, [App, User,AppManager, UserManager, dAppstore]);
  deployer.link(StringUtils, [App, User,AppManager, UserManager, dAppstore]);
  deployer.link(AddressUtils, [App, User,AppManager, UserManager, dAppstore]);
  deployer.link(AddressPayableUtils, [App, User,AppManager, UserManager, dAppstore]);
  deployer.link(AppInfoLibrary, [App, User,AppManager, UserManager, dAppstore]);
  deployer.deploy(AppManager);
  deployer.deploy(UserManager);
  deployer.deploy(dAppstore);
};
