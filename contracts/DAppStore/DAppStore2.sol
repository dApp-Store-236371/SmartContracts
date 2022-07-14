//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;
import {User} from '../Users/User.sol';
import {App} from '../Apps/App.sol';
import {Constants} from '../Utils/Constants.sol';
import {StringUtils} from '../Utils/StringUtils.sol';
import {AddressUtils, AddressPayableUtils} from '../Utils/AddressUtils.sol';
import {Events} from '../Utils/Events.sol';
import {AppInfoLibrary} from '../Utils/AppInfoLibrary.sol';
import {UserManager} from '../Users/UserManager.sol';
import {AppManager} from '../Apps/AppManager.sol';
import {Verify} from '../Utils/SignatureVerifier.sol';

import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";



contract DAppStore{
    using StringUtils for string;
    using AddressUtils for address;
    using AddressPayableUtils for address payable;
    using Strings for uint;

    UserManager private userManager;
    AppManager private appManager;
    Verify private verifier;
    uint private key_length = 10;
    string constant random_string = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    // events
    
    constructor(){
        userManager = new UserManager();
        appManager = new AppManager();
        verifier = new Verify();
    }
    
    function getRandomString(uint _length) private returns (string memory){
        string memory key = '';
        for (uint i = 0; i < _length; i++){
            key = key.append(random_string[i:i]);
        }
        return key;
    }

    function registerUser() external {
        string memory key = getRandomString(key_length);
        userManager.createUser(key);
    }

}