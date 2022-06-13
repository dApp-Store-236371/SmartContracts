//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;
library AppInfoLibrary {
    struct AppInfo{
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
        string magnetLink;
        uint publishTime;
    }

    struct AppShortInfo{
        uint id;
        string name;
    }



    // function getAppShortInfo(uint _id) view external returns(AppShortInfo memory){
    //     return "";
    // }

    // function getAppFullInfo(uint _id) view external returns(AppFullInfo memory){
    //     return "";
    // }
}
