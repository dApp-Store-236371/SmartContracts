pragma solidity ^0.8.0;

contract User {
    //App contract provides a data structure of auser and
    //an API to work with for external use
    //TODO: Create interface for minimalistic app data (app_id, rated, owned, name[optional])

    struct UserRating{
        uint app_id;
        uint app_rating;
    }


    address payable private owner;
    addres
    bool is_publisher;
    mapping(uint => uint) private app_ratings;
    uint[] rated_apps;
    uint[] purchased_apps; // maybe combined with rated_apps and add a boolean
    uint[] created_apps;

    constructor(uint new_user_id, string memory new_user_name){
        owner = payable(msg.sender);
        user_id = new_user_id;
        user_name = new_user_name;
        is_publisher = false;
    }


    //Validation
    modifier validateOwner() {
        require(owner == msg.sender);
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

    function add_created_app(uint _app_id) external validateID(_app_id){
        created_apps.push(_app_id);
    }

    function publish_app()pure external{
        uint x;
        x=5;
    }

    // function update_app(uint _app_id, string new_sha){
    //
    // }

    //Getters
    function get_purchased_apps() view external validateOwner returns(uint[] memory){
        return purchased_apps;
    }

    function get_created_apps() view external validateOwner returns(uint[] memory){
        return created_apps;
    }

    function get_rated_apps() view external validateOwner returns(uint[] memory){
        return rated_apps;
    }

    //Updaters
    function purchase_app(uint _app_id) external validateOwner validateID(_app_id){
        purchased_apps.push(_app_id);
    }

    function rate_app(uint _app_id, uint _app_rating) external validateOwner validateID(_app_id){
        rated_apps.push(_app_id);
        app_ratings[_app_id] = _app_rating;
    }


}
