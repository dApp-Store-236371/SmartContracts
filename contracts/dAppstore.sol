//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;
import {User} from './user.sol';
import {App} from './app.sol';
import {Constants, Events, StringUtils, AddressUtils} from './dappstore_utils.sol';
import {AppInfoLibrary} from './AppInfoLibrary.sol';

import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract dAppstore {
    using StringUtils for string;
    using AddressUtils for address;
    using AddressUtils for address payable;
    
    using Strings for uint;
    // using Address for address payable;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Counters for Counters.Counter;

    // app_id => app_contract
    EnumerableMap.UintToAddressMap private apps;
    // user_address => user_contract
    mapping(address => address) users;
    Counters.Counter users_num;

    constructor() {
        users_num.reset();
    }

    //Validators
    modifier userExists(address _user_address){
        require(!_user_address.isAddressZero(), "Invalid addr");
        require(!users[_user_address].isAddressZero(), 'User not found');
        _;
    }

    modifier userDoesNotExists(address _user_address){
        require(!_user_address.isAddressZero(), "Invalid addr");
        require(users[_user_address].isAddressZero(), 'User not found');
        _;
    }

    modifier appExists(uint _app_id){
        require(apps.contains(_app_id), 'App not found');
        require(!apps.get(_app_id).isAddressZero(), 'App doens\'t exists');
        _;
    }

    modifier onlyCreator(uint _app_id, address _app_creator){
        require(!_app_creator.isAddressZero(), 'Invalid addr');
        require(_app_creator == App(apps.get(_app_id)).creator(), 'not creator addr');
        _;
    }

    modifier validIndex(uint _index, uint _length){
        require(_index >= 0, 'Invalid index');
        require(_length > 0, 'Invalid length');
        _;
    }

    //
    function createNewUser(address user_address) private {
        users_num.increment();
        users[user_address] = address(new User(payable(user_address)));
        emit Events.UserCreated(payable(user_address), users[user_address]);
    }

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
        if (users[msg.sender].isAddressZero()){
            createNewUser(msg.sender);
        }
        uint apps_num = apps.length();
        App new_app = new App(
            apps_num,
            payable(msg.sender),
            _name,
            _description,
            _magnetLink,
            _imgUrl,
            _company,
            _price,
            _category,
            _fileSha256
        );


        // App new_app = new App(
        //     apps_num, 
        //     msg.sender, 
        //     _name, 
        //     _description, 
        //     _magnetLink, 
        //     _imgUrl, 
        //     _company, 
        //     _price, 
        //     _category,
        //     _fileSha256
        // );
        apps.set(apps_num, address(new_app));
        User(users[msg.sender]).createNewApp(address(new_app));
        emit Events.AppCreated(_name, apps_num, payable(msg.sender));
    }

    function updateApp(
        uint app_id,
        string memory _name,
        string memory _description,
        string memory _magnetLink,
        string memory _imgUrl,
        // string memory _company,
        uint _price,
        string memory _fileSha256
    ) external userExists(msg.sender) appExists(app_id) onlyCreator(app_id, msg.sender) {
        App(apps.get(app_id)).updateApp(
            _name,
            _description,
            _magnetLink,
            _imgUrl,
            _price,
            _fileSha256
        );

    }



    //todo: Add appnotopwned into purchaseApp
    function purchaseApp(uint app_id) external payable appExists(app_id) { //todo: check this validate
        address user = msg.sender;
        if (users[user].isAddressZero()){
            createNewUser(user);
        }
        
        address app_address = apps.get(app_id);
        require(!User(users[user]).isAppOwned(app_address), 'Can\'t buy app twice');

        App app = App(app_address);
        (bool sent,) = app.creator().call{value: msg.value}(""); //sends ether to the creator
        require(sent, "Failed to send Ether");
        User(users[user]).markAppAsPurchased(app_address);
        emit Events.UserPurchasedApp(payable(user), app_address);
        // require(false, 'DEBUG MESSAGE');
    }


    // //todo: return app info via struct instead of addresses
    function getAppBatch(uint start, uint len) view external validIndex(start, len) returns( AppInfoLibrary.AppInfo[] memory){
        bool registered = !users[msg.sender].isAddressZero();
        uint apps_length = apps.length();
        uint requested_apps = (len < apps_length? len: apps_length);
        AppInfoLibrary.AppInfo[] memory batch = new AppInfoLibrary.AppInfo[](requested_apps);
        require (requested_apps <= len && requested_apps <= apps_length, "minimum failed");
        for (uint i = 0; i < requested_apps; i++){
            address app_address = apps.get((start + i) % apps_length);
            bool owned = registered && User(users[msg.sender]).isAppOwned(app_address);
            batch[i] = App(app_address).getAppInfo(owned);
        }
        return batch;
    }

    // Not registered user is going to see empty list
    function getPurchasedAppsInfo() external view returns(AppInfoLibrary.AppInfo[] memory){
        if (users[msg.sender].isAddressZero()){
            AppInfoLibrary.AppInfo[] memory empty_app_arr;
            return  empty_app_arr;
        }
        AppInfoLibrary.AppInfo[] memory purchased_apps_info = User(users[msg.sender]).getPurchasedApps();
        return purchased_apps_info;
    }

    // Not registered user is going to see empty list
    function getPublishedAppsInfo() external view returns(AppInfoLibrary.AppInfo[] memory){
        if (users[msg.sender].isAddressZero()){
            AppInfoLibrary.AppInfo[] memory empty_app_arr;
            return  empty_app_arr;
        }
        return User(users[msg.sender]).getPublishedApps();
    }

    function getRatedAppsInfo() external view returns(AppInfoLibrary.AppInfo[] memory){
        if (users[msg.sender].isAddressZero()){
            AppInfoLibrary.AppInfo[] memory empty_app_arr;
            return  empty_app_arr;
        }
        // AppInfoLibrary.AppInfo[] memory rated_apps_info = User(users[msg.sender]).getRatedApps();
        // return rated_apps_info;
        return User(users[msg.sender]).getRatedApps();
    }

    function getAppCount() view external returns(uint){
        return apps.length();
    }

    function getAppRating(uint _app_id) view external appExists(_app_id) returns(uint, uint, uint){
        App app = App(apps.get(_app_id));
        (uint rating_int, uint rating_modulu) = app.getAppRating();
        return (rating_int, rating_modulu, app.num_ratings());
    }

    //Rating
    function rateApp(uint _app_id, uint new_rating) external{
        //todo: inc num of ratings on app
        User user = User(users[msg.sender]);
        address app_address = apps.get(_app_id);
        App curr_app = App(app_address);

        uint old_rating = user.getRatingForApp(app_address);
        user.rateApp(app_address, new_rating);
        (uint rating_int, uint rating_modulu, uint num_ratings) = curr_app.rateApp(new_rating, old_rating);
        emit Events.AppRated(_app_id, rating_int, rating_modulu, num_ratings);

    }

    // function createXApps(uint num_apps) external{
    //     uint num_existing_apps = apps.length();
    //     for (uint i = num_existing_apps; i < num_existing_apps + num_apps; i++){
    //         string memory  idx = i.toString();
    //         createNewApp(
    //             idx.prepend('GO GO APP #'),
    //             idx.prepend('GO GO DESCRIPTION #'),
    //             Constants.DEFAULT_APP_MAGNET_LINK,
    //             Constants.DEFAULT_APP_IMAGE,
    //             idx,
    //             i + 1,
    //             idx
    //         );
    //     }
    // }
   
}
