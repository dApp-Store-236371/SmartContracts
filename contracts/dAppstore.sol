pragma solidity ^0.8.0;

//TODO: refactor interfaces to external file, import file here


interface IUser{
    //TODO: Needs to be updated according to User contract
    function create_new_app();
    function publish_app();
    function update_app();
    function rate_app();
    function purchase_app();
    function get_purchased_apps();
    function get_created_apps();

}

interface IApp{
    //TODO: Needs to be updated according to App contract
    function update_app();
    function publish_app();
    function get_app_rank();
}


contract dAppstore {
    //dappstore will use App and User interfaces to manage data
    //users and apps
    IApp[] apps;
    IUser[] users;

    function create_new_app(){}
    function update_app(){}
    function purchase_app(){}

    function create_new_user(){}

    function get_ranked_apps(){}

}
