pragma solidity ^0.8.0;

library AppInfoLibrary {
    struct AppFullInfo{
        uint id;
        string name;
        string description;
        string imgUrl;
        string company;
        uint price;
        uint num_ratings;
        uint rating;
        uint rating_modulu;
        string fileSha256;
        bool owned;
    }

    struct AppShortInfo{
        uint id;
        string name;
    }

    function getAppShortInfo(uint _id) view external returns(AppShortInfo memory){
        return "";
    }

    function getAppFullInfo(uint _id) view external returns(AppFullInfo memory){
        return "";
    }
}