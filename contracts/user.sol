//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;
import {App} from './app.sol';
import {Constants, Events, StringUtils, AddressUtils} from './dappstore_utils.sol';
import {AppInfoLibrary} from './AppInfoLibrary.sol';

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

contract User is Ownable{
    using AddressUtils for address;
    using Counters for Counters.Counter;

    address payable private user_address;
    bool isPublisher;
    address[] private purchasedApps;
    address[] private createdApps;
    mapping (address => bool) private ownedApps;
    mapping (address => uint) private appRatings;
    mapping (address => uint) private downloaded_apps;
    Counters.Counter appsRated;
    constructor(address new_user_address){
        user_address = payable(new_user_address);
        isPublisher = false;
        appsRated.reset();
    }

    //Validation
    modifier validateRating(uint _rating){
        require(_rating > 0);
        _;
    }

    //Getters
    function isAppOwned(address app_address) external view  onlyOwner returns(bool){
        return ownedApps[app_address];
    }
        
    function getRatingForApp(address app) view public onlyOwner returns(uint){
        return appRatings[app];
    }

    function getPurchasedApps() view external onlyOwner returns(AppInfoLibrary.AppInfo[] memory){
        uint len = purchasedApps.length;
        AppInfoLibrary.AppInfo[] memory purchasedApps_info = new AppInfoLibrary.AppInfo[](len);
        for (uint i = 0; i < len; i++){
            App _app = App(purchasedApps[i]);
            purchasedApps_info[i] = _app.getAppInfo(true, getRatingForApp(purchasedApps[i]));
        }
        return purchasedApps_info;
    }

    function getPublishedApps() view external onlyOwner returns(AppInfoLibrary.AppInfo[] memory){
        uint len = createdApps.length;
        AppInfoLibrary.AppInfo[] memory publishedAppsInfo = new AppInfoLibrary.AppInfo[](len);
        for (uint i = 0; i < len; i++){
            App _app = App(createdApps[i]);
            publishedAppsInfo[i] = _app.getAppInfo(true, getRatingForApp(createdApps[i]));
        }
        return publishedAppsInfo;
    }

    function getRatedApps() view external onlyOwner returns(AppInfoLibrary.AppInfo[] memory){
        uint len = appsRated.current();
        AppInfoLibrary.AppInfo[] memory rated_apps_info = new AppInfoLibrary.AppInfo[](len);
        for (uint i = 0; i < len; i++){
            address app_address = purchasedApps[i];
            App _app = App(app_address);
            if (appRatings[app_address] > 0){
                rated_apps_info[i] = _app.getAppInfo(true, getRatingForApp(purchasedApps[i]));
            }
        }
        return rated_apps_info;
    }

    //Updaters
    function createNewApp(address app) external onlyOwner{
        isPublisher = true;
        createdApps.push(app);
        markAppAsPurchased(app);
    }

    function rateApp(address app, uint app_rating) external onlyOwner{
        require(app_rating >=1 && app_rating <=5);
        if (appRatings[app] == 0){
            appsRated.increment();
        }
        appRatings[app] = app_rating;
    }

    function markAppAsPurchased(address app_address) public onlyOwner{
        purchasedApps.push(app_address);
        ownedApps[app_address] = true;
    }


}