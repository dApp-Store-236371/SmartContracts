pragma solidity ^0.8.0;
import {User} from './user.sol';
import {App} from './app.sol';
import {dappstore_utils} from './dappstore_utils.sol';
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
    //dappstore will use App and User interfaces to manage data
    //users and apps
    // IApp[] apps;
    // IUser[] users;
    mapping(uint => address) users;
    mapping(uint => address) apps;
    uint users_num;
    uint apps_num;

    function create_new_app(string memory _name, string memory _description,
            string memory _magnetLink, string memory _imgUrl,
            string memory _company, uint _price, string memory _fileSha256) external{
        apps_num += 1;
        App new_app = new App(apps_num, _name, _description, _magnetLink, _imgUrl, _company, _price, _fileSha256);
        apps[apps_num] = address(new_app);
    }
    function update_app(uint app_id, string memory _name,
                        string memory _description, string memory _magnetLink,
                        string memory _imgUrl, string memory _company,
                        uint _price, string memory _fileSha256) external{
        address app = apps[app_id];
        // app.up
    }
    // function purchase_app(){}

    function create_new_user(string calldata user_name) external{
        users_num += 1;
        User new_user = new User(users_num, user_name);
        users[users_num] = address(new_user);
    }

    function rate_app(uint _app_id, uint _rating) external{
        App curr_app = App(apps[_app_id]);
        uint curr_rating = curr_app.get_num_ratings();
        if (curr_rating == 0){
            curr_app.rate_app(_rating, true, 0);
        }
        else if (curr_rating > dappstore_utils.RATING_THRESHHOLD){
            curr_app.rate_app(_rating, false, curr_app.get_app_rating());
        }

    }

    function change_buckets(App app, uint from, uint to) pure private returns(bool){
        // require(true, 'not implements change_buckets');
        return false;
    }

}
