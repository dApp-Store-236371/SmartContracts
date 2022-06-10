//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import {User} from './user.sol';
import {App} from './app.sol';
import {Constants, Events, StringUtils, AddressUtils} from './dappstore_utils.sol';
import {AppInfoLibrary} from './AppInfoLibrary.sol';

import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol"; //todo: Use for payment

contract dAppstore {
    using StringUtils for string;
    using AddressUtils for address;
    using AddressUtils for address payable;
    
    using Strings for uint;
    // using Address for address payable;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Counters for Counters.Counter;
    string constant public name = "dAppstore";

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

    modifier appAddressExists(address _app){
        uint _app_id = App(_app).id();
        require(apps.contains(_app_id), 'App not found');
        require(!apps.get(_app_id).isAddressZero(), 'App exists');
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
        require(apps.contains(_index), 'Invalid index');
        require(_length > 0, 'Invalid length');
        _;
    }

    function createNewUser(address user_address) private {
        users_num.increment();
        users[user_address] = address(new User(payable(user_address)));
    }

    function createNewApp(
        address creator,
        string memory _name,
        string memory _description,
        string memory _magnetLink,
        string memory _imgUrl,
        string memory _company,
        uint _price,
        string memory _fileSha256
    ) public{
        if (users[creator].isAddressZero()){
            createNewUser(creator);
        }
        uint apps_num = apps.length();
        App new_app = new App(
            apps_num, 
            creator, 
            _name, 
            _description, 
            _magnetLink, 
            _imgUrl, 
            _company, 
            _price, 
            _fileSha256
        );
        apps.set(apps_num, address(new_app));
    }

    function updateApp(
        uint app_id,
        string memory _name,
        string memory _description,
        string memory _magnetLink,
        string memory _imgUrl,
        string memory _company,
        uint _price,
        string memory _fileSha256
    ) external userExists(msg.sender) appExists(app_id) onlyCreator(app_id, msg.sender) {
        App app = App(apps.get(app_id));
        if (!_name.isEmpty()){
            app.updateAppName(_name);
        }
        if (!_description.isEmpty()){
            app.updateAppDescription(_description);
        }
        if (!_magnetLink.isEmpty()){
            app.updateAppMagnetLink(_magnetLink);
        }
        if (!_imgUrl.isEmpty()){
            app.updateAppImgUrl(_imgUrl);
        }
        if (!_company.isEmpty()){
            app.updateAppCompany(_company);
        }
        if (_price > 0){
            app.updateAppPrice(_price);
        }
        if (!_fileSha256.isEmpty()){
            app.updateAppVersion(_fileSha256);
        }
    }

    function purchaseApp(address app_address) external userExists(msg.sender) appAddressExists(app_address){ //todo: check this validate
        address user = msg.sender;
        if (users[user].isAddressZero()){
            createNewUser(user);
        }
        Address.sendValue(App(app_address).creator(), App(app_address).price());
        User(user).purchaseApp(app_address);
    }

    // function rateApp(uint _app_id, uint _rating) external{
    //     //todo: inc num of ratings on app
    //     App curr_app = App(apps.get(_app_id));
    //     uint curr_rating = curr_app.num_ratings;
    //     if (curr_rating == 0){
    //         curr_app.rateApp(0, 0, _rating);
    //     }
    //     else if (curr_rating > Constants.RATING_THRESHHOLD){
    //         (uint curr_rating, uint curr_rating_modulu) = curr_app.getAppRating();
    //         curr_app.rateApp(curr_rating, curr_rating_modulu, _rating);
    //     }
    // }

    // function changeBuckets(App app, uint from, uint to) pure private returns(bool){
    //     // require(true, 'not implements change_buckets');
    //     return false;
    // }

    // //todo: return app info via struct instead of addresses
    function getAppBatch(uint start, uint len) view external validIndex(start, len) returns( AppInfoLibrary.AppInfo[] memory){
        AppInfoLibrary.AppInfo[] memory batch = new AppInfoLibrary.AppInfo[](len);
        for (uint i = 0; i < len; i++){
            batch[i] = App(apps.get((start + i) % apps.length())).getAppInfo();
        }
        return batch;
    }

    // Not registered user is going to see empty list
    function getPurchasedAppsInfo() private returns(AppInfoLibrary.AppInfo[] memory){
        if (users[msg.sender].isAddressZero()){
            createNewUser(msg.sender);
        }
        AppInfoLibrary.AppInfo[] memory purchased_apps_info = User(users[msg.sender]).getPurchasedApps();
        return purchased_apps_info;
    }

    // Not registered user is going to see empty list
    function getCreatedAppsInfo() private returns(AppInfoLibrary.AppInfo[] memory){
        if (users[msg.sender].isAddressZero()){
            createNewUser(msg.sender);
        }
        AppInfoLibrary.AppInfo[] memory created_apps_info = User(users[msg.sender]).getCreatedApps();
        return created_apps_info;
    }

    function getRatedAppsInfo() private returns(AppInfoLibrary.AppInfo[] memory){
        if (users[msg.sender].isAddressZero()){
            createNewUser(msg.sender);
        }
        AppInfoLibrary.AppInfo[] memory rated_apps_info = User(users[msg.sender]).getRatedApps();
        return rated_apps_info;
    }

    // //todo: remove from here to test file
    // function generateDemoApps(uint number_of_apps) public{
    //     uint existing_apps = apps.length();
    //     for (uint i = existing_apps; i < existing_apps + number_of_apps; i++){
    //         string memory app_idx = i.toString();
    //             createNewApp(
    //             msg.sender,
    //             app_idx.prepend('name'),
    //             app_idx.prepend('description'),
    //             app_idx.prepend('link'),
    //             app_idx.prepend('img'),
    //             app_idx.prepend('company'),
    //             8,
    //             app_idx.prepend('fileSha')
    //         );
    //     }       
    // }
}
