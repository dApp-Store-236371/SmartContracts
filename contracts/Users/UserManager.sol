//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {App} from '../Apps/App.sol';
import {User} from './User.sol';
import {Constants} from '../Utils/Constants.sol';
import {StringUtils} from '../Utils/StringUtils.sol';
import {AddressUtils, AddressPayableUtils} from '../Utils/AddressUtils.sol';
import {AppInfoLibrary} from '../Utils/AppInfoLibrary.sol';



import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

contract UserManager is Ownable{
    using AddressUtils for address;
    using AddressPayableUtils for address payable;
    using Counters for Counters.Counter;

    //user_address => user_contract
    mapping(address => address) users;

    constructor(){}

    // Modifiers:
    modifier validAddress(address _user_address){
        require(!_user_address.isAddressZero(), "Invalid user address");
        _;
    }

    modifier validateUserExists(address _user_address){
        require(!_user_address.isAddressZero(), "Invalid user address");
        require(!users[_user_address].isAddressZero(), 'User not found');
        _;
    }

    // Getters:
    function userExists() public view
    onlyOwner
    validAddress(msg.sender)
    returns (bool){
        return !users[msg.sender].isAddressZero();
    }

    function getUser(address _userAddress) private view returns(address){
        return users[_userAddress];
    }

    function getPublishedApps() external view 
    onlyOwner
    validateUserExists(msg.sender)
    returns (AppInfoLibrary.AppInfo[] memory){
        AppInfoLibrary.AppInfo[] memory publishedAppsInfo = User(users[msg.sender]).getPublishedApps();
        return publishedAppsInfo;
    }

    function getPurchasedAppsInfo() external view
    onlyOwner
    validateUserExists(msg.sender)
    returns(AppInfoLibrary.AppInfo[] memory){
        AppInfoLibrary.AppInfo[] memory purchasedApps_info = User(users[msg.sender]).getPurchasedApps();
        return purchasedApps_info;
    }

    function getRatedApps() external view
    onlyOwner
    validateUserExists(msg.sender)
    returns (AppInfoLibrary.AppInfo[] memory){
        AppInfoLibrary.AppInfo[] memory rated_apps_info = User(users[msg.sender]).getRatedApps();
        return rated_apps_info;
    }

    function getUserRating(address _app_address) external view 
    onlyOwner
    validateUserExists(msg.sender)
    returns (uint _rating){
        return User(users[msg.sender]).getRatingForApp(_app_address);
    }

    function isUserAppOwner(address _app_address) external view 
    validateUserExists(msg.sender)
    returns(bool){
        User user = User(getUser(msg.sender));
        return user.isAppOwned(_app_address);
    }

    function isUserAppCreator(address _app_address) external view
    validateUserExists(msg.sender)
    returns(bool){
        User user = User(getUser(msg.sender));
        return user.isCreator(_app_address);
    }

    // Create and modify users:
    function createUser(string calldata key) external 
    onlyOwner
    validateUserExists(msg.sender){
        require (!users[msg.sender].isAddressZero(), "User already exists");
        users[msg.sender] = address(new User(payable(msg.sender), key));
    }

    function createNewApp(address _appAddress) external
    onlyOwner
    validateUserExists(msg.sender){
        User(users[msg.sender]).createNewApp(_appAddress);
    }

    function markAppAsPurchased(address _appAddress) external
    onlyOwner
    validateUserExists(msg.sender){
        User(users[msg.sender]).markAppAsPurchased(_appAddress);
    }

    function markAppAsRated(address _appAddress, uint _rating) external
    onlyOwner
    validateUserExists(msg.sender){
        User(users[msg.sender]).rateApp(_appAddress, _rating);
    }
}