pragma solidity ^0.8.0;
import {User} from './user.sol';
import {App} from './app.sol';
import {constants, events, string_utils } from './dappstore_utils.sol';

contract dAppstore {
    address payable user_address;
    address dapp_store;
    mapping(address => address) users;
    mapping(uint => address) apps;
    uint users_num;
    uint apps_num;

    //Validators
    modifier validateUserExist(address _user_address){
        require(users[_user_address] != address(0), 'User does not exist');
        _;
    }

    modifier validateAppExists(uint _app_id){
        require(apps[_app_id] != address(0), 'App does not exist');
        _;
    }

    function createNewApp(address payable creator, string memory _name, string memory _description,
            string memory _magnetLink, string memory _imgUrl,
            string memory _company, uint _price, string memory _fileSha256) external{
        apps_num += 1;
        App new_app = new App(apps_num, creator, _name, _description, _magnetLink, _imgUrl, _company, _price, _fileSha256);
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
        app.updateAppFileSha(_fileSha256);
    }

    function createNewUser(address payable user_address) private validateUserExist(user_address) {
        users_num += 1;
        users[user_address] = address(new User(user_address));
    }

    function purchaseApp(address app) external{
        address user = msg.sender;
        if (users[user] == address(0)){
            createNewUser(payable(user));
        }
        User(user).purchaseApp(app);
    }

    function rateApp(uint _app_id, uint _rating) external{
        App curr_app = App(apps[_app_id]);
        uint curr_rating = curr_app.getNumRatings();
        if (curr_rating == 0){
            curr_app.rateApp(0, 0, _rating);
        }
        else if (curr_rating > constants.RATING_THRESHHOLD){
            (uint curr_rating, uint curr_rating_modulu) = curr_app.getAppRating();
            curr_app.rateApp(curr_rating, curr_rating_modulu, _rating);
        }
    }

    function changeBuckets(App app, uint from, uint to) pure private returns(bool){
        // require(true, 'not implements change_buckets');
        return false;
    }

}
