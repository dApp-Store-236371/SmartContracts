//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;
import {App} from './app.sol';
import {Constants, Events, StringUtils, AddressUtils} from './dappstore_utils.sol';
import {AppInfoLibrary} from './AppInfoLibrary.sol';

import "@openzeppelin/contracts/access/Ownable.sol";

contract User is Ownable{
    using AddressUtils for address;

    address payable user_address;
    address dapp_store;
    bool is_publisher;
    address[] purchased_apps;
    address[] created_apps;
    mapping (address => uint) app_ratings;
    mapping (address => uint) downloaded_apps;

    constructor(address new_user_address){
        dapp_store = msg.sender;
        user_address = payable(new_user_address);
        is_publisher = false;
        emit Events.UserCreated(user_address, address(this), dapp_store);
    }

    //Validation
    modifier validateDappStore() {
        require(dapp_store == msg.sender);
        _;
    }

    modifier validateID(uint _id){
        require(_id > 0);
        _;
    }

    modifier validateRating(uint _rating){
        require(_rating > 0);
        _;
    }

    //Getters
    function getPurchasedApps() view external onlyOwner returns(AppInfoLibrary.AppInfo[] memory){
        uint len = purchased_apps.length;
        AppInfoLibrary.AppInfo[] memory purchased_apps_info = new AppInfoLibrary.AppInfo[](len);
        for (uint i = 0; i < len; i++){
            App _app = App(purchased_apps[i]);
            purchased_apps_info[i] = _app.getAppInfo(true);
        }
        return purchased_apps_info;
    }

    function getCreatedApps() view external onlyOwner returns(AppInfoLibrary.AppInfo[] memory){
        uint len = created_apps.length;
        AppInfoLibrary.AppInfo[] memory created_apps_info = new AppInfoLibrary.AppInfo[](len);
        for (uint i = 0; i < len; i++){
            App _app = App(created_apps[i]);
            created_apps_info[i] = _app.getAppInfo(true);
        }
        return created_apps_info;
    }

    function getRatedApps() view external onlyOwner returns(AppInfoLibrary.AppInfo[] memory){
        uint len = purchased_apps.length;
        AppInfoLibrary.AppInfo[] memory rated_apps_info = new AppInfoLibrary.AppInfo[](len);
        for (uint i = 0; i < len; i++){
            App _app = App(purchased_apps[i]);
            rated_apps_info[i] = _app.getAppInfo(true);
        }
        return rated_apps_info;
    }

    function getRatingForApp(address app) view external onlyOwner returns(uint){
        return app_ratings[app];
    }

    function isAppPurchased(address _app) view external onlyOwner returns(bool){
        for (uint i = 0; i < purchased_apps.length; i++){
            if (_app.isEqual(purchased_apps[i])){
                return true;
            }
        }
        return false;
    }

    //Updaters
    function creatApp(address app) external onlyOwner{
        is_publisher = true;
        created_apps.push(app);
        purchased_apps.push(app);
    }

    function rateApp(address app, uint app_rating) external onlyOwner{
        require(app_rating >=1 && app_rating <=5);
        app_ratings[app] = app_rating;
    }

    function purchaseApp(address app_address) external onlyOwner{
        purchased_apps.push(app_address);
    }

    function isAppOwned(address app_address) external view  onlyOwner returns(bool){
        for (uint i=0; i < purchased_apps.length; i++){
            if (purchased_apps[i].isEqual(app_address)){
                return true;
            }
        }
        return false;
    }
}