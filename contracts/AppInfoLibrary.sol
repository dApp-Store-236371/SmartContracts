//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;
library AppInfoLibrary {
    struct AppInfo{
        uint id;
        string name;
        string description;
        string imgUrl;
        string company;
        uint price;
        uint numRatings;
        uint ratingInt;
        uint ratingModulu;
        uint userRating;
        string fileSha256;
        bool owned;
        string magnetLink;
        string category;
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
