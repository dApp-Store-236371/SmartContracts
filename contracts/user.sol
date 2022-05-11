pragma solidity ^0.8.0;

contract user {
    //App contract provides a data structure of auser and
    //an API to work with for external use
    //TODO: Create interface for minimalistic app data (app_id, rated, owned, name[optional])


    uint owner;
    uint user_id;
    string user_name;
    bool is_publisher;
    uint[] rated_apps;
    uint[] purchased_apps; // maybe combined with rated_apps and add a boolean
    uint[] created_apps;

    constructor(uint new_user_id, string new_user_name) public{
        user_id = new_user_id;
        user_name = new_user_name;
        is_publisher = false;
//        rate
    }

    function create_new_app(){

    }

    function publish_app(){

    }

    function update_app(uint app_id, string new_sha){

    }

    function rate_app(uint app_id){

    }

    function purchase_app(uint app_id){

    }

    //show my apps?
    function get_purchased_apps(){

    }

    //for search by creator
    function get_created_apps(){

    }


}
