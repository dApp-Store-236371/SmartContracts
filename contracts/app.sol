pragma solidity ^0.8.0;

import {dappstore_utils} from './dappstore_utils.sol';
import {User} from './user.sol';
// import {dAppstore} from './dAppstore.sol';

import "@openzeppelin/contracts/utils/Strings.sol";

contract App {
    //App contract provides a data structure of an app and
    //an API to work with for external use

    uint256  id;
    string  name;
    string  description;
    address payable  creator;
    string[]  fileSha256; //last is SHA of latest version.
    string magnetLink;
    string imgUrl;
    string company;
    uint  rating; //0 means not rated
    uint rating_modulu;
    uint price; //in wei
    uint num_ratings;

    constructor(uint _id,
                string memory _name,
                string memory _description,
                string memory _magnetLink,
                string memory _imgUrl,
                string memory _company,
                uint _price,
                string memory _fileSha256)
                validateID(_id) validatePrice(_price) validateString(_name)
                validateString(_magnetLink) validateString(_fileSha256)
    {
    // require(1>2, "Passed validations");
    creator = payable(msg.sender);
    id  = _id;
    name  = _name;
    description = _description;

    magnetLink = _magnetLink;
    if (check_if_string_empty(_imgUrl)){
        imgUrl = dappstore_utils.DEFAULT_APP_IMAGE;
    } else{
        imgUrl = _imgUrl;
    }
    company = _company;
    rating = dappstore_utils.UNRATED;
    rating_modulu = dappstore_utils.UNRATED;
    price = _price;
    num_ratings = 0;
    fileSha256.push(_fileSha256);
    }

    // receive() external payable{}

    //valdiations
    modifier validateID(uint _id){
        require(_id > 0, 'Illegal app id');
        _;
    }

    // modifier validateAppExists(uint _id){
    //     uint apps_num = dAppstore(msg.sender).get_apps_num();
    //     require (_id > 0 && _id < apps_num);
    //     _;
    // }

    // modifier validateUserExists(uint _id){
    //     uint users_num = dAppstore(msg.sender).get_users_num();
    //     require (_id > 0 && _id < users_num);
    //     _;
    // }

    modifier validatePrice(uint _price){
        require(_price > 0, 'Price must be greater than 0');
        _;
    }

    modifier validateString(string memory _string){
        require(check_if_string_empty(_string), 'String must not be empty');
        _;
    }

    modifier validateOwner(){
        require(msg.sender == creator, 'Sender is not app owner');
        _;
    }

    function check_if_string_empty(string memory _string) pure private returns(bool){
        return bytes(_string).length > 0;
    }

    //getters
    function getName() public view returns(string memory){
        return name;
    }

    function getDescription() external view returns(string memory){
        return description;
    }

    function getImgUrl() external view returns(string memory){
        return imgUrl;
    }

    function getCompany() external view returns(string memory){
        return company;
    }

    function getPrice() external view returns(uint){
        return price;
    }

    function getCurrentVersion() external view returns(string memory){
        return fileSha256[fileSha256.length - 1];
    }

    function getAppRating() external view returns (uint){
        if (rating <= 0){
            return 0;
        }
    return rating;
    }

    function getNumRatings() external view returns(uint){
        return num_ratings;
    }

    //updaters


    function updateAppName(string calldata new_name) external validateOwner validateString(new_name){
        emit dappstore_utils.UpdatedContent('updated name', name, new_name, msg.sender);
        name = new_name;
    }

    function updateAppDescription(string calldata new_description) external validateOwner validateString(new_description){
        emit dappstore_utils.UpdatedContent('updated description', description, new_description, msg.sender);
        description = new_description;
    }

    function updateAppImagUrl(string calldata new_imgUrl) external validateOwner validateString(new_imgUrl){
        emit dappstore_utils.UpdatedContent('updated imgUrl', imgUrl, new_imgUrl, msg.sender);
        imgUrl = new_imgUrl;
    }

    function updateAppVersion(string memory new_sha) external validateOwner validateString(new_sha) {
        emit dappstore_utils.UpdatedContent('updated sha', fileSha256[fileSha256.length - 1], new_sha, msg.sender);
        fileSha256.push(new_sha);
    }

    function updateCompany(string calldata new_company) external validateOwner validateString(new_company){
        emit dappstore_utils.UpdatedContent('updated company', company, new_company, msg.sender);
        company = new_company;
    }

    function updateAppPrice(uint new_price) external validateOwner validatePrice(new_price){
        emit dappstore_utils.UpdatedContent('updated price', Strings.toString(price), Strings.toString(new_price), msg.sender);
        price = new_price;
    }


    function rateApp(address rating_user, uint new_rating) external validateOwner returns(uint, uint){
        uint rating_by_user = User(rating_user).getAppRating();
        require(rating_by_user >= 0 && rating_by_user <=5);
        uint total_rating = rating * num_ratings + rating_modulu;
            num_ratings += 1;
        total_rating += new_rating - rating_by_user;
        rating = total_rating / num_ratings;
        rating_modulu = total_rating % num_ratings;
        return (rating, rating_modulu);
        }

    // function rate_app_old(uint new_rating, bool first_rating, uint old_rating) external {
    //     require(new_rating > 0 && new_rating <=5, "illegal rating");
    //     if (new_rating == dappstore_utils.UNRATED){
    //         require(first_rating == true, "App has no previous ratings");
    //         rating = new_rating;
    //     } else if (first_rating == true){
    //         rating = (rating * num_ratings + new_rating) / num_ratings + 1;
    //         num_ratings = num_ratings + 1;
    //     } else {
    //         require(old_rating > 0 && old_rating <=5, "illegal rating");
    //         uint rating_mid = rating * num_ratings - old_rating ;
    //         rating = (rating_mid + new_rating) / num_ratings;
    //     }
    // }


    //most likely not needed
    // function update_app_info(string calldata new_name, string calldata new_description,
    //                          string calldata new_imgUrl) external validateOwner{
    //     if (check_if_string_empty(new_name)){
    //         update_app_name(new_name);
    //     }
    //     if (check_if_string_empty(new_description)) {
    //         update_app_description(new_description);
    //     }
    //     if (check_if_string_empty(new_imgUrl)){
    //         update_app_image(new_imgUrl);
    //     }
    // }






}


