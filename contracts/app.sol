pragma solidity ^0.8.0;


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
    int  rating; //-1 means not rated
    uint price; //in wei
    uint RatingsNum;

    bool owned; //will be filled by getter functions.
    int myRating;


    constructor(){

    }

    function update_app(uint app_id, string new_sha){

    }

    function publish_app(){

    }



}
