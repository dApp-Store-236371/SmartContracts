pragma solidity ^0.8.0;
import {dappstore_utils} from './dappstore_utils.sol'; //import

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
    uint price; //in wei
    uint RatingsNum;

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
    price = _price;
    RatingsNum = 0;
    fileSha256.push(_fileSha256);
    }

    // receive() external payable{}

    //valdiations
    modifier validateID(uint _id){
        require(_id > 0, 'Illegal app id');
        _;
    }

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

    function check_if_string_empty(string memory _string)
    pure private returns(bool){
        return bytes(_string).length > 0;
    }

    //getters
    function get_name() public view returns(string memory){
        require(false, 'name');
        return name;
    }

    function get_description() external view returns(string memory){
        return description;
    }

    function get_img_url() external view returns(string memory){
        return imgUrl;
    }

    function get_company() external view returns(string memory){
        return company;
    }

    function get_price() external view returns(uint){
        return price;
    }

    function get_current_version() external view returns(string memory){
        return fileSha256[fileSha256.length - 1];
    }

    function get_app_rating() external view returns (uint){
        if (rating < 0){
            return 0;
        }
    return rating;
    }

    //updaters
    function update_app_version(string memory new_sha) public validateOwner validateString(new_sha) {
        fileSha256.push(new_sha);
    }

    function update_app_name(string calldata new_name) private validateString(new_name){
        name = new_name;
    }

    function update_app_description(string calldata new_description) private validateString(new_description){
        description = new_description;
    }

    function update_app_image(string calldata new_imgUrl) private validateString(new_imgUrl){
        imgUrl = new_imgUrl;
    }

    function update_app_info(string calldata new_name, string calldata new_description,
                             string calldata new_imgUrl) external validateOwner{
        if (check_if_string_empty(new_name)){
            update_app_name(new_name);
        }
        if (check_if_string_empty(new_description)) {
            update_app_description(new_description);
        }
        if (check_if_string_empty(new_imgUrl)){
            update_app_image(new_imgUrl);
        }
    }

    function update_app_price(uint new_price)
    public validateOwner validatePrice(new_price){
        price = new_price;
    }

    function rate_app(uint new_rating, bool first_rating, uint old_rating) external {
        require(new_rating > 0 && new_rating <=5, "illegal rating");
        if (new_rating == dappstore_utils.UNRATED){
            require(first_rating == true, "App has no previous ratings");
            rating = new_rating;
        } else if (first_rating == true){
            rating = (rating * RatingsNum + new_rating) / RatingsNum + 1;
            RatingsNum = RatingsNum + 1;
        } else {
            require(old_rating > 0 && old_rating <=5, "illegal rating");
            uint rating_mid = rating * RatingsNum - old_rating ;
            rating = (rating_mid + new_rating) / RatingsNum;
        }
    }








}


