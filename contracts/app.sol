pragma solidity ^0.8.0;

import {constants, events, string_utils } from './dappstore_utils.sol';

import "@openzeppelin/contracts/utils/Strings.sol";

contract App {
    //App contract provides a data structure of an app and
    //an API to work with for external use
    using string_utils for string;
    address dapp_store;
    uint256  id;
    address creator;
    string  name;
    string  description;
    string[]  fileSha256; //last is SHA of latest version.
    string magnetLink;
    string imgUrl;
    string company;
    uint  rating; //0 means not rated
    uint rating_modulu;
    uint price; //in wei
    uint num_ratings;

    constructor(uint _id,
                address creator,
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
    dapp_store = msg.sender;
    creator = payable(creator);
    id  = _id;
    name  = _name;
    description = _description;

    magnetLink = _magnetLink;
    imgUrl = _imgUrl;
    if(_imgUrl.isEmpty()){
        imgUrl = constants.DEFAULT_APP_IMAGE;
    }
    company = _company;
    rating = constants.UNRATED;
    rating_modulu = constants.UNRATED;
    price = _price;
    num_ratings = 0;
    fileSha256.push(_fileSha256);
    // emit events.AppCreated(id, name, creator, dapp_store);
    }

    //valdiations
    modifier validateID(uint _id){
        require(_id > 0, 'Illegal app id');
        _;
    }

    modifier validateRating(uint _rating){
        require(_rating >=0 && _rating <=5);
        _;
    }

    modifier validatePrice(uint _price){
        require(_price > 0, 'Price must be greater than 0');
        _;
    }

    modifier validateString(string memory _string){
        require(!_string.isEmpty(), 'String must not be empty');
        _;
    }

    modifier validateDappStore(){
        require(msg.sender == dapp_store, 'Sender is not app owner');
        _;
    }

    //getters
    function getID() external view returns(uint){
        return id;
    }

    function getName() external view returns(string memory){
        return name;
    }

    function getCreator() external view returns(address memory){
        return creator;
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

    function getAppRating() external view returns (uint, uint){
        if (rating <= 0){
            return (0, 0);
        }
    return (rating, rating_modulu);
    }

    function getNumRatings() external view returns(uint){
        return num_ratings;
    }

    //updaters
    function updateAppName(string calldata new_name) external validateDappStore validateString(new_name){
        emit events.UpdatedContent('updated name', name, new_name, msg.sender);
        name = new_name;
    }

    function updateAppDescription(string calldata new_description) external validateDappStore validateString(new_description){
        emit events.UpdatedContent('updated description', description, new_description, msg.sender);
        description = new_description;
    }

    function updateAppImagUrl(string calldata new_imgUrl) external validateDappStore validateString(new_imgUrl){
        emit events.UpdatedContent('updated imgUrl', imgUrl, new_imgUrl, msg.sender);
        imgUrl = new_imgUrl;
    }

    function updateAppVersion(string memory new_sha) external validateDappStore validateString(new_sha) {
        emit events.UpdatedContent('updated sha', fileSha256[fileSha256.length - 1], new_sha, msg.sender);
        fileSha256.push(new_sha);
    }

    function updateCompany(string calldata new_company) external validateDappStore validateString(new_company){
        emit events.UpdatedContent('updated company', company, new_company, msg.sender);
        company = new_company;
    }

    function updateAppPrice(uint new_price) external validateDappStore validatePrice(new_price){
        emit events.UpdatedContent('updated price', Strings.toString(price), Strings.toString(new_price), msg.sender);
        price = new_price;
    }


    function rateApp(uint old_rating, uint new_rating) external
    validateDappStore validateRating(old_rating) validateRating(new_rating) returns(uint, uint){
        require(new_rating >= 1, 'Can\'t give 0 stars');
        uint total_rating = rating * num_ratings + rating_modulu;
        if (old_rating == 0){
            num_ratings += 1;
        }
        //TODO: Make sure subtraction is validated (Maybe OpenZepplin?)
        total_rating += new_rating - old_rating;
                rating = total_rating / num_ratings;
        rating_modulu = total_rating % num_ratings;
        return (rating, rating_modulu);
        }

}


