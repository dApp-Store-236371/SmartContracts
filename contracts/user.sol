pragma solidity ^0.8.0;
import {App} from './app.sol';
import {constants, events, string_utils } from './dappstore_utils.sol';

contract User {

    address payable user_address;
    address dapp_store;
    bool is_publisher;
    address[] purchased_apps;
    address[] created_apps;
    mapping (address => uint) app_ratings;
    mapping (address => uint) downloaded_apps;

    constructor(address payable new_user_address){
        dapp_store = msg.sender;
        user_address = new_user_address;
        is_publisher = false;
        emit events.UserCreated(new_user_address, address(this), dapp_store);
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

    function addCreatedApp(address app) external{
        created_apps.push(app);
    }

    //Getters
    function getPurchasedApps() view external validateDappStore returns(address[] memory){
        return purchased_apps;
    }

    function getCreatedApps() view external validateDappStore returns(address[] memory){
        return created_apps;
    }

    function getRatedApps() view external validateDappStore returns(address[] memory){
        address[] memory rated_apps;
        for(uint i; i < purchased_apps.length; i++){
            address app = purchased_apps[i];
            if (app_ratings[app] != 0){
                rated_apps[rated_apps.length] = app;
            }
        }
        return rated_apps;
    }

    function getRatingForApp(address app) view external validateDappStore returns(uint){
        return app_ratings[app];
    }

    //Updaters
    function creatApp(address app) external validateDappStore{
        is_publisher = true;
        created_apps.push(app);
    }

    function rateApp(address app, uint app_rating) external validateDappStore{
        require(app_rating >=1 && app_rating <=5);
        app_ratings[app] = app_rating;
    }

    function purchaseApp(address app_address) external validateDappStore{
        purchased_apps.push(app_address);
        App app = App(app_address);
        address payable user = app.getCreator();
        uint price = app.getPrice();
        payCreator(user, price);
    }

    function payCreator(address payable creator, uint price) public payable validateDappStore{
        creator.transfer(price);
    }
}


