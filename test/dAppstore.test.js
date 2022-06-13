var chai = require("chai");
const expect = chai.expect;
const assert = chai.assert;

const DAppStore = artifacts.require("dAppstore");

// Start test block
contract('dAppStore', function () {
    beforeEach(async function () {
      // Deploy a new Box contract for each test
      this.DAppStore = await DAppStore.new();
    });
  
    // Test case
    it('Create x apps for same user', async function () {
        const user_address = "0x0000000000000000000000000000000000000001";
        const x_apps = 10;
        for (i = 0; i < x_apps; i++) {
            idx_suffix = toString(i);
            await this.DAppStore.createNewApp(
                user_address,
                "name" + idx_suffix,
                "description" + idx_suffix,
                "link" + idx_suffix, 
                "img" + idx_suffix,
                "company" + idx_suffix,
                8,
                "fileSha" + idx_suffix
            );
        }
        const app_count = await this.DAppStore.getAppCount();
        await expect(app_count).to.equal(x_apps);
    });

    it('Update App', async function () {
        
    });

    it('User purchases app', async function () {
        
    });

    it('Get user created apps', async function () {
        
    });
  });


