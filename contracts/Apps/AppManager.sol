//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {App} from './App.sol';
import {User} from '../Users/User.sol';
import {Constants} from '../Utils/Constants.sol';
import {StringUtils} from '../Utils/StringUtils.sol';
import {AddressUtils, AddressPayableUtils} from '../Utils/AddressUtils.sol';
import {Events} from '../Utils/Events.sol';
import {AppInfoLibrary} from '../Utils/AppInfoLibrary.sol';

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract AppManager is Ownable{
    using StringUtils for string;
    using AddressUtils for address;
    using AddressUtils for address payable;
    
    using Strings for uint;
    // using Address for address payable;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Counters for Counters.Counter;

    // app_id => app_contract
    EnumerableMap.UintToAddressMap private apps;

    
    // events
    event AppCreated(
        uint indexed id,
        address payable indexed creator,
        string name,
        string company,
        string category,
        uint price, 
        string description
        //maybe more fields
    );

    event UpdatedApp(
        uint indexed app_id
    );
    
    constructor(){

    }

    // Modifiers:
    modifier appExists(uint _app_id){
        require(apps.contains(_app_id), 'App not found');
        require(!apps.get(_app_id).isAddressZero(), 'App doens\'t exists');
        _;
    }

    modifier validIndex(uint _index, uint _length){
        require(_index >= 0, 'Invalid index');
        require(_length > 0, 'Invalid length');
        require(_index < apps.length(), 'Invalid index');
        _;
    }

    // Getters:
    function getAppBatch(uint start, uint len) view external validIndex(start, len) returns(AppInfoLibrary.AppInfo[] memory){
        uint apps_length = apps.length();
        uint requested_apps = (len < apps_length? len: apps_length);
        AppInfoLibrary.AppInfo[] memory batch = new AppInfoLibrary.AppInfo[](requested_apps);

        require (requested_apps <= len && requested_apps <= apps_length, "minimum failed");
        for (uint i = 0; i < requested_apps; i++){
            uint app_id = (start + i) % apps_length;
            address app_address = apps.get(app_id);
            batch[i] = App(app_address).getAppInfo();
        }
        return batch;
    }
        
    function getAppCount() view external returns(uint){
        return apps.length();
    }

    // Create and modify apps:
        function createNewApp(
        string memory _name,
        string memory _description,
        string memory _magnetLink,
        string memory _imgUrl,
        string memory _company,
        uint _price,
        string memory _category,
        string memory _fileSha256
    ) public{
        uint apps_num = apps.length();
        App new_app = new App(
            apps_num, 
            msg.sender, 
            _name, 
            _description, 
            _magnetLink, 
            _imgUrl, 
            _company, 
            _price, 
            _category,
            _fileSha256
        );
        apps.set(apps_num, address(new_app));
        emit AppCreated(
            apps_num, 
            payable(msg.sender),
            _name,
            _company,
            _category,
            _price,
            _description
        );
    }

    function updateApp(
        uint _app_id,
        string calldata _name,
        string calldata _description,
        string calldata _magnetLink,
        string calldata _imgUrl,
        uint _price,
        string calldata _fileSha256
    ) external onlyOwner{

        App app = App(apps.get(_app_id));

        if (_magnetLink.isNotEmpty() || _fileSha256.isNotEmpty()){
            require(_magnetLink.isNotEmpty() && _fileSha256.isNotEmpty(), 'Must provide both magnet link and file sha256');
            app.updateAppVersion(_fileSha256, _magnetLink);
        }
        if (_name.isNotEmpty()){
            app.updateAppName(_name);
        }
        if (_description.isNotEmpty()){
            app.updateAppDescription(_description);
        }
        if (_imgUrl.isNotEmpty()){
            app.updateAppImgUrl(_imgUrl);
        }
        if (_price > 0){
            app.updateAppPrice(_price);
        }
    }

    // App rating:
        function rateApp(uint _app_id, uint new_rating, uint old_rating) external{
        address app_address = apps.get(_app_id);
        App curr_app = App(app_address);
        (uint rating_int, uint rating_modulu, uint num_ratings) = curr_app.rateApp(new_rating, old_rating);
        emit Events.AppRated(_app_id, rating_int, rating_modulu, num_ratings);
    }
    
}