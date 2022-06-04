pragma solidity ^0.8.0;
import {User} from './user.sol';
import {App} from './app.sol';
import {constants, events, string_utils } from './dappstore_utils.sol';
//TODO: refactor interfaces to external file, import file here


// interface IUser{
//     //TODO: Needs to be updated according to User contract
//     function external create_new_app();
//     function external publish_app();
//     function update_app();
//     function rate_app();
//     function purchase_app();
//     function get_purchased_apps();
//     function get_created_apps();

// }

// interface IApp{
//     //TODO: Needs to be updated according to App contract
//     function update_app();
//     function publish_app();
//     function get_app_rank();
// }


contract dAppstore {
    address payable user_address;
    address dapp_store;
    mapping(address => address) users;
    mapping(uint => address) apps;
    uint users_num;
    uint apps_num;

    //Validators
    modifier validateUserExist(address _user_address){
        require(users[_user_address] == 0, 'User does not exist');
        _;
    }

    modifier validateAppExists(uint _app_id){
        require(apps[_app_id] != 0, 'App does not exist');
        _;
    }

    function createNewApp(address creator, string memory _name, string memory _description,
            string memory _magnetLink, string memory _imgUrl,
            string memory _company, uint _price, string memory _fileSha256) external{
        apps_num += 1;
        App new_app = new App(apps_num, _name, _description, _magnetLink, _imgUrl, _company, _price, _fileSha256);
        apps[apps_num] = address(new_app);
    }

    function updateApp(uint app_id, address _app, string memory _name,
                        string memory _description, string memory _magnetLink,
                        string memory _imgUrl, string memory _company,
                        uint _price, string memory _fileSha256) external validateAppExists(app_id){
        App app = App(_app);
        app.updateAppName(_name);
        app.updateAppDescription(_description);
        app.updateAppImagUrl(_imgUrl);
        app.updateAppMagnetLink(_magnetLink);
        app.updateAppCompany(_company);
        app.updateAppPrice(_price);
        app.updateAppFileSha256(_fileSha256);
    }

    function createNewUser(address user_address) validateUserDoesNotExist(user_address) {
        users_num += 1;
        users[user_address] = address(new User(user_address));
    }

    function purchaseApp(address app){
        address user = msg.sender;
        user.purchaseApp(app);
    }

    function rateApp(uint _app_id, uint _rating) external{
        App curr_app = App(apps[_app_id]);
        uint curr_rating = curr_app.get_num_ratings();
        if (curr_rating == 0){
            curr_app.rate_app(_rating, true, 0);
        }
        else if (curr_rating > dappstore_utils.RATING_THRESHHOLD){
            curr_app.rate_app(_rating, false, curr_app.get_app_rating());
        }
    }

    function changeBuckets(App app, uint from, uint to) pure private returns(bool){
        // require(true, 'not implements change_buckets');
        return false;
    }

}
