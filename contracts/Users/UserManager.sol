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
    constructor(){

    }

    // Modifiers:

    // Getters:
    function getUser(address _userAddress) private view{
        
    }

    function getPublishedApps(address _userAddress) external view returns (AppInfoLibrary.AppInfo[] memory){
        
    }

    function getPurchasedApps(address _userAddress) external view returns (AppInfoLibrary.AppInfo[] memory){
        
    }

    function getRatedApps(address _userAddress) external view returns (AppInfoLibrary.AppInfo[] memory){
        
    }

    function getUserRating(address _userAddress, uint _appId) external view returns (uint _rating){
        
    }

    // Create and modify users:
    // creates new user, returns a string that is used as a user id/password
    function createUser(address _userAddress) external returns(string memory){
        
    }

    function createNewApp(address _userAddress, uint _appId) external returns(bool _success){
        
    }

    function markAppAsPurchased(address _userAddress, uint _appId) external returns(bool _success){
        
    }
}