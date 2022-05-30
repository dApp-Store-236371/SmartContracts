// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol";

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../contracts/app.sol";
import {dappstore_utils} from "../contracts/dappstore_utils.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite {
    App app;
    uint app_id = 1;
    string app_name = 'app name';
    string app_description = 'app desc';
    string magnet_link = 'magnet_link';
    string img_url = 'img url';
    string app_company = 'app company';
    uint price = 8;
    string filesha = 'filesha';
    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        // <instantiate contract>
        App app = new App(app_id, app_name, app_description, magnet_link, img_url,
                          app_company, price, filesha);
        Assert.equal(bytes(app.get_name()).length, bytes(app_name).length, "name should be app name");
    }

    function check_update_app_info() public {
        string memory new_app_name = 'new app name';
        string memory new_description;
        string memory new_imgUrl;
        string memory n = app.get_name();
        // app.update_app_info(new_app_name, dappstore_utils.DEFAULT_EMPTY,dappstore_utils.DEFAULT_EMPTY);
        // Assert.equal(app.get_name(), new_app_name, "names should be the same");
    }

    function checkSuccess() public {
        // Use 'Assert' methods: https://remix-ide.readthedocs.io/en/latest/assert_library.html
        Assert.ok(2 == 2, 'should be true');
        Assert.greaterThan(uint(2), uint(1), "2 should be greater than to 1");
        Assert.lesserThan(uint(2), uint(3), "2 should be lesser than to 3");
    }

    function checkSuccess2() public pure returns (bool) {
        // Use the return value (true or false) to test the contract
        return true;
    }

    function checkFailure() public {
        Assert.notEqual(uint(1), uint(2), "1 should not be equal to 1");
    }

    /// Custom Transaction Context: https://remix-ide.readthedocs.io/en/latest/unittesting.html#customization
    /// #sender: account-1
    /// #value: 100
    function checkSenderAndValue() public payable {
        // account index varies 0-9, value is in wei
        Assert.equal(msg.sender, TestsAccounts.getAccount(1), "Invalid sender");
        Assert.equal(msg.value, 100, "Invalid value");
    }
}
