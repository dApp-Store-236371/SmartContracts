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
    using Address for address payable;
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
        require(!_user_address.isAddressZero(), "User address is not valid");
        require(!users[_user_address].isAddressZero(), 'User does not exist');
        _;
    }

    modifier userDoesNotExists(address _user_address){
        require(!_user_address.isAddressZero(), "User address is not valid");
        require(users[_user_address].isAddressZero(), 'User does not exist');
        _;
    }

    modifier appAddressExists(address _app){
        uint _app_id = App(_app).id();
        require(apps.contains(_app_id), 'App does not exist');
        require(apps.get(_app_id).isAddressZero(), 'App already exists');
        _;
    }

    modifier appExists(uint _app_id){
        require(apps.contains(_app_id), 'App does not exist');
        require(apps.get(_app_id).isAddressZero(), 'App already exists');
        _;
    }

    modifier onlyCreator(uint _app_id, address _app_creator){
        require(!_app_creator.isAddressZero(), 'App creator address is not valid');
        App _app = App(apps.get(_app_id));
        require(_app_creator == _app.creator(), 'User is not the same as the app creator');
        _;
    }

    modifier validIndex(uint _index, uint _length){
        require(apps.contains(_index), 'Index is not valid');
        require(_length <= apps.length(), 'Length is not valid');
        _;
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
    ) external{
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

    function createNewUser(address user_address) private userDoesNotExists(user_address) {
        users_num.increment();
        users[user_address] = address(new User(payable(user_address)));
    }

    function purchaseApp(address app) external appAddressExists(app){ //todo: check this validate
        //todo: import "@openzeppelin/contracts/utils/Address.sol";
        //todo: inc num of purchases on app
        //todo: check if user has enough money [optional]
        //todo: move entire purchase procedure here, user.sol and app.sol only update what happened (markAsPurchased, etc)
        address user = msg.sender;
        if (users[user].isAddressZero()){
            createNewUser(user);
        }
        App _app = App(app);
        uint price = _app.price();
        address payable creator = _app.creator();
        Address.sendValue(creator, price);
        User(user).purchaseApp(app);
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

    //todo: return app info via struct instead of addresses
    function getAppBatch(uint start, uint len) view external validIndex(start, len) returns( AppInfoLibrary.AppInfo[] memory){
        AppInfoLibrary.AppInfo[] memory batch = new AppInfoLibrary.AppInfo[](len);
        for (uint i = 0; i < len; i++){
            App _app = App(apps.get((start + i) % apps.length()));
            batch[i] = _app.getAppInfo();
        }
        return batch;
    }



    // Not registered user is going to see empty list
    function getPurchasedAppsInfo() private returns(AppInfoLibrary.AppInfo[] memory){
        if (users[msg.sender].isAddressZero()){
            createNewUser(msg.sender);
        }
        User _user = User(users[msg.sender]);
        AppInfoLibrary.AppInfo[] memory purchased_apps_info = _user.getPurchasedApps();
        return purchased_apps_info;
    }

    // Not registered user is going to see empty list
    function getCreatedAppsInfo() private returns(AppInfoLibrary.AppInfo[] memory){
        if (users[msg.sender].isAddressZero()){
            createNewUser(msg.sender);
        }
        User _user = User(users[msg.sender]);
        AppInfoLibrary.AppInfo[] memory created_apps_info = _user.getCreatedApps();
        return created_apps_info;
    }

    function getRatedAppsInfo() private returns(AppInfoLibrary.AppInfo[] memory){
        if (users[msg.sender].isAddressZero()){
            createNewUser(msg.sender);
        }
        User _user = User(users[msg.sender]);
        AppInfoLibrary.AppInfo[] memory rated_apps_info = _user.getRatedApps();
        return rated_apps_info;
    }


    function generateDemoApps(uint number_of_apps) public{
        uint existing_apps = apps.length();
        for (uint i = existing_apps; i < existing_apps + number_of_apps; i++){
            string memory app_idx = i.toString();
            string memory app_name = string('name').append(app_idx);
            string memory app_description = string('description').append(app_idx);
            string memory app_link = string('link').append(app_idx);
            string memory app_img = string('img').append(app_idx);
            string memory app_company = string('company').append(app_idx);
            uint app_price = 8;
            string memory app_fileSha = string('fileSha').append(app_idx);

            this.createNewApp(
                msg.sender,
                app_name,
                app_description,
                app_link,
                app_img,
                app_company,
                app_price,
                app_fileSha
            );
        }       
    }
}
