pragma solidity ^0.8.0;

contract User {
    //App contract provides a data structure of auser and

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

    function add_created_app(address app) external{
        created_apps.push(app);
    }

    //Getters
    function get_purchased_apps() view external validateDappStore returns(address[] memory){
        return purchased_apps;
    }

    function get_created_apps() view external validateDappStore returns(address[] memory){
        return created_apps;
    }

    function get_rated_apps() view external validateDappStore returns(address[] memory){
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
    function purchase_app(address app) external validateDappStore{
        purchased_apps.push(app);
    }

    function creatApp(address app) external validateDappStore{
        is_publisher = true;
        created_apps.push(app);
    }

    function rate_app(address app, uint app_rating) external validateDappStore{
        require(app_rating >=1 && app_rating <=5);
        app_ratings[app] = app_rating;
    }
}
