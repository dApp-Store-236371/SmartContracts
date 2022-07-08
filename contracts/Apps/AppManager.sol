//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {App} from './App.sol';
import {Constants} from '../Utils/Constants.sol';
import {StringUtils} from '../Utils/StringUtils.sol';
import {AddressUtils, AddressPayableUtils} from '../Utils/AddressUtils.sol';
import {AppInfoLibrary} from '../Utils/AppInfoLibrary.sol';

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

contract AppManager is Ownable{
    constructor(){

    }

    // Modifiers:


    // Getters:
    function getApp(uint _appId) private view returns (address){
        
    }

    function getAppBatch(uint start, uint length) external view returns (AppInfoLibrary.AppInfo[] memory){
        
    }
        
    function getAppCount() external view returns (uint){
        
    }

    // Create and modify apps:
    function createApp(
        string memory _name, 
        string memory _description, 
        string memory _image,
        string memory _url) external returns(uint _appId){
        
    }

    function updateApp(
        uint _appId, 
        string memory _name, 
        string memory _description, 
        string memory _image,
        string memory _url) external returns(bool _success){
        
    }

    // App rating:
    function rateApp(
        uint _appId, 
        uint _rating) external returns(bool _success){
        
    }
    
}