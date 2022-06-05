pragma solidity ^0.8.0;

import {Constants, Events, StringUtils} from './dappstore_utils.sol';

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract App is Ownable {
    //App contract provides a data structure of an app and
    //an API to work with for external use
    using StringUtils for string;
    using Counters for Counters.Counter;
    uint256 public  id;
    address payable public creator;
    string public name;
    string public description;
    string[] fileSha256; //last is SHA of latest version.
    string public magnetLink;
    string public imgUrl;
    string public company;
    uint rating_int; //0 means not rated
    uint rating_modulu;
    uint public price; //in wei
    Counters.Counter public num_ratings;
    Counters.Counter public num_purchases;

    constructor(uint _id,
                address payable creator,
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
    creator = creator;
    id  = _id;
    name  = _name;
    description = _description;

    magnetLink = _magnetLink;
    imgUrl = _imgUrl;
    if(_imgUrl.isEmpty()){
        imgUrl = Constants.DEFAULT_APP_IMAGE;
    }
    company = _company;
    rating_int = Constants.UNRATED;
    rating_modulu = Constants.UNRATED;
    price = _price;
    fileSha256.push(_fileSha256);
    num_ratings.reset();
    num_purchases.reset();
    emit Events.AppCreated(name, id, creator, owner());
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

    //getters
    function getCurrentVersion() external view returns(string memory){
        return fileSha256[fileSha256.length - 1];
    }

    function getAppRating() external view returns (uint, uint){
        if (rating_int <= 0){
            return (0, 0);
        }
    return (rating_int, rating_modulu);
    }

    //updaters
    function updateAppName(string calldata new_name) external onlyOwner validateString(new_name){
        emit Events.UpdatedContent('updated name', name, new_name, msg.sender);
        name = new_name;
    }

    function updateAppDescription(string calldata new_description) external onlyOwner validateString(new_description){
        emit Events.UpdatedContent('updated description', description, new_description, msg.sender);
        description = new_description;
    }

    function updateAppImagUrl(string calldata new_imgUrl) external onlyOwner validateString(new_imgUrl){
        emit Events.UpdatedContent('updated imgUrl', imgUrl, new_imgUrl, msg.sender);
        imgUrl = new_imgUrl;
    }

    function updateAppMagnetLink(string calldata new_magnetLink) external onlyOwner validateString(new_magnetLink){
        emit Events.UpdatedContent('updated new_magnetLink', magnetLink, new_magnetLink, msg.sender);
        magnetLink = new_magnetLink;
    }
    function updateAppVersion(string memory new_sha) external onlyOwner validateString(new_sha) {
        emit Events.UpdatedContent('updated sha', fileSha256[fileSha256.length - 1], new_sha, msg.sender);
        fileSha256.push(new_sha);
    }

    function updateAppCompany(string calldata new_company) external onlyOwner validateString(new_company){
        emit Events.UpdatedContent('updated company', company, new_company, msg.sender);
        company = new_company;
    }

    function updateAppPrice(uint new_price) external onlyOwner validatePrice(new_price){
        emit Events.UpdatedContent('updated price', Strings.toString(price), Strings.toString(new_price), msg.sender);
        price = new_price;
    }


    function updateAppFileSha(string calldata new_filesha) external onlyOwner validateString(new_filesha){
        emit Events.UpdatedContent('updated filesha', fileSha256[fileSha256.length - 1], new_filesha, msg.sender);
        fileSha256.push(new_filesha);
    }

    function rateApp(uint old_rating, uint old_rating_modulu, uint new_rating) external
    onlyOwner validateRating(old_rating) validateRating(new_rating) returns(uint, uint){
        require(new_rating >= 1, 'Can\'t give 0 stars');
        uint total_rating = rating_int * num_ratings.current() + rating_modulu;
        if (old_rating == 0){
            num_ratings.increment();
        }
        //TODO: Make sure subtraction is validated (Maybe OpenZepplin?)
        total_rating += new_rating - old_rating;
        rating_int = total_rating / num_ratings.current();
        rating_modulu = total_rating % num_ratings.current();
        return (rating_int, rating_modulu);
        }

}


