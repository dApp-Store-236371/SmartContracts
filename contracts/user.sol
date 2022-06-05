pragma solidity ^0.8.0;
import {App} from './app.sol';
import {Constants, Events, StringUtils} from './dappstore_utils.sol';
import {AppInfoLibrary} from './AppInfoLibrary.sol';

import "@openzeppelin/contracts/access/Ownable.sol";

contract User is Ownable{

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
        emit Events.UserCreated(new_user_address, address(this), dapp_store);
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
    function getPurchasedApps() view external onlyOwner returns(App[] memory){
        return App(purchased_apps);
    }

    function getCreatedApps() view external onlyOwner returns(App[] memory){
        return App(created_apps);
    }

    function getRatedApps() view external onlyOwner returns(App[] memory){
        address[] memory rated_apps;
        for(uint i; i < purchased_apps.length; i++){
            address app = purchased_apps[i];
            if (app_ratings[app] != 0){
                rated_apps[rated_apps.length] = app;
            }
        }
        return App(rated_apps);
    }

    function getRatingForApp(address app) view external onlyOwner returns(uint){
        return app_ratings[app];
    }

    //Updaters
    function creatApp(address app) external onlyOwner{
        is_publisher = true;
        created_apps.push(app);
    }

    function rateApp(address app, uint app_rating) external onlyOwner{
        require(app_rating >=1 && app_rating <=5);
        app_ratings[app] = app_rating;
    }

    function purchaseApp(address app_address) external onlyOwner{
        App app = App(app_address);
        address payable user = app.getCreator();
        uint price = app.getPrice();
        payCreator(user, price);
        purchased_apps.push(app_address);
    }

    function payCreator(address payable creator, uint price) public payable onlyOwner{
        creator.transfer(price);
    }


    //how to convert address to instance of App?
    //answer: use App(address)
    //how to convert array of address to array of instance of Apps?
    //answer: use App(address)[]
    //type(App[addres(0), address(0)]):
}


