const { expect } = require('chai');
const User = artifacts.require("User");

// Start test block
contract('App contract', function () {
    beforeEach(async function () {
      // Deploy a new Box contract for each test
      this.User = await User.new(
        "0x0000000000000000000000000000000000000000",
      );
    });
  
    // Test case
    it('retrieve returns a value previously stored', async function () {
      // Store a value
    //   await this.DAppStore.createNewUser(address(0));
  
      // Test if the returned value is the same one
      // Note that we need to use strings to compare the 256 bit integers
    //   expect((await this.DAppStore.retrieve()).toString()).to.equal('42');
    });
  });