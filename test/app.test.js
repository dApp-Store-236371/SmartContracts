const { expect } = require('chai');
const App = artifacts.require("App");

// Start test block
contract('App contract', function () {
    beforeEach(async function () {
        const fileSha = "fileSha0";
        const price = 8;
        const company = "company";
        const img = "img";
        const link = "link";
        const description = "description";
        const name = "name";
        const user_address = "0x0000000000000000000000000000000000000000";
        const app_id = 0;
      // Deploy a new Box contract for each test
      this.App = await App.new(
        app_id,
        user_address,
        name,
        description,
        link,
        img,
        company,
        price,
        fileSha
      );
    });
  
    // // Test case
    // it('AppInfo returns correct values', async function () {
    //   const appInfo = await AppInfoLibrary.AppInfo.new(
    //     app_id,
    //     name,
    //     description,
    //     img,
    //     company,
    //     price,
    //     0,
    //     0,
    //     0,
    //     fileSha,
    //     false
    //   );
    //   expect((await this.DAppStore.retrieve()).toString()).to.equal('42');
    // });
  });