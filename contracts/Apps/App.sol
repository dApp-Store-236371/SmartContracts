//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {Constants} from '../Utils/Constants.sol';
import {StringUtils} from '../Utils/StringUtils.sol';
import {AddressUtils, AddressPayableUtils} from '../Utils/AddressUtils.sol';

import {AppInfoLibrary} from '../Utils/AppInfoLibrary.sol';

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract App is Ownable {
    //App contract provides a data structure of an app and
    //an API to work with for external use
    using StringUtils for string;
    using StringUtils for string;

    using Counters for Counters.Counter;
    using SafeMath for uint;

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
    string category;
    uint publishTime;
    Counters.Counter public num_ratings;
    Counters.Counter public num_purchases;

    constructor(uint _id,
                address _creator,
                string memory _name,
                string memory _description,
                string memory _magnetLink,
                string memory _imgUrl,
                string memory _company,
                uint _price,
                string memory _category,
                string memory _fileSha256)
                validateID(_id) validatePrice(_price) validateString(_name)
                validateString(_magnetLink) validateString(_category) validateString(_fileSha256)
    {
    creator = payable(_creator);
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
    category = _category;
    publishTime = block.timestamp;
    }

    //valdiations
    modifier validateID(uint _id){
        require(_id >= 0, 'Illegal app id');
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
    function getCurrentVersion() public view returns(string memory){
        return fileSha256[fileSha256.length - 1];
    }

    function getAppRating() external view returns (uint, uint){
        if (rating_int <= 0){
            return (0, 0);
        }
    return (rating_int, rating_modulu);
    }

    //updaters
    function updateAppName(string calldata new_name) external validateString(new_name){
        name = new_name;
    }

    function updateAppDescription(string calldata new_description) external validateString(new_description){
        description = new_description;
    }

    function updateAppImgUrl(string calldata new_imgUrl) external validateString(new_imgUrl){
        imgUrl = new_imgUrl;
    }

    function updateAppVersion(string memory new_sha, string calldata new_magnetLink) external 
    validateString(new_sha)
    validateString(new_magnetLink){
        magnetLink = new_magnetLink;
        fileSha256.push(new_sha);
    }

    // function updateAppCompany(string calldata new_company) private validateString(new_company){
    //     company = new_company;
    // }

    function updateAppPrice(uint new_price) external validatePrice(new_price){
       price = new_price;
    }


    // function updateApp(
    //     string calldata _name,
    //     string calldata _description,
    //     string calldata _magnetLink,
    //     string calldata _imgUrl,
    //     uint _price,
    //     string calldata _fileSha256
    // ) external onlyOwner returns(bool){
    //     bool updated = false;
    //     if (!_name.isEmpty()){
    //         updateAppName(_name);
    //         updated = true;
    //     }
        // if (_description.isNotEmpty()){
        //     updateAppDescription(_description);
        // }
        // if (_magnetLink.isNotEmpty() || _fileSha256.isNotEmpty()){
        //     // require(_magnetLink.isNotEmpty() && _fileSha256.isNotEmpty(), StringUtils.append(_magnetLink.getVariableMessage("magnet link"), _fileSha256.getVariableMessage("file sha256")));
        //     require(_magnetLink.isNotEmpty() && _fileSha256.isNotEmpty(), 'Must provide both magnet link and file sha256');
        //     updateAppMagnetLink(_magnetLink);
        //     updateAppVersion(_fileSha256);
        // }
        // if (_imgUrl.isNotEmpty()){
        //     updateAppImgUrl(_imgUrl);
        // }
        // if (_price > 0){
        //     updateAppPrice(_price);
        // }
    //     return updated;
    // }

    function rateApp(uint new_rating, uint old_rating) external 
    onlyOwner 
    validateRating(old_rating) 
    validateRating(new_rating)
    returns(uint, uint, uint)
    {
        uint total_rating = rating_int * num_ratings.current() + rating_modulu;
        if (old_rating == 0){
            num_ratings.increment();
        }
        // require(num_ratings.current() > 0, 'Invalid number of ratings');
        total_rating += new_rating;
        total_rating -= old_rating;
        rating_int = total_rating / num_ratings.current();
        rating_modulu = total_rating % num_ratings.current();
    return (rating_int, rating_modulu, num_ratings.current());
    }


    function getAppInfo(bool owned, uint user_rating) view external returns(AppInfoLibrary.AppInfo memory){
        // (uint rating, uint rating_modulu) = _app.getAppRating();
        AppInfoLibrary.AppInfo memory app_info = AppInfoLibrary.AppInfo(
            id,
            name,
            description,
            imgUrl,
            company,
            price,
            num_ratings.current(),
            rating_int,
            rating_modulu,
            user_rating,
            getCurrentVersion(),
            owned,
            owned? magnetLink: '',
            category,
            publishTime
        );
        return app_info;
    }

    
    function getAppInfo() view external returns(AppInfoLibrary.AppInfo memory){
        // (uint rating, uint rating_modulu) = _app.getAppRating();
        AppInfoLibrary.AppInfo memory app_info = AppInfoLibrary.AppInfo(
            id,
            name,
            description,
            imgUrl,
            company,
            price,
            num_ratings.current(),
            rating_int,
            rating_modulu,
            0,
            getCurrentVersion(),
            false,
            '',
            category,
            publishTime
        );
        return app_info;
    }

}


