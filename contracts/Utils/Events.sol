//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {AppInfoLibrary} from './AppInfoLibrary.sol';

library Events {
    // event AppCreated(
    //     uint indexed id,
    //     address payable indexed creator,
    //     string name,
    //     string company,
    //     string category,
    //     uint price, 
    //     string description
    //     //maybe more fields
    // );

    event UserCreated(
        address payable indexed user_address,
        address indexed user_contract
    );

    event UserPurchasedApp(
        address payable indexed buyer,
        address indexed app_id
    );

    event UpdatedContent(
        uint indexed app_id,
        string indexed content_type,
        string indexed new_content,
        string previous_content,
        address sender
    );

    event AppRated(
        uint indexed app_id,
        uint rating_int,
        uint rating_modulu,
        uint num_ratings
    );

    event UpdatedApp(
        uint indexed app_id
    );

    event AppInfo(
        AppInfoLibrary.AppInfo
    );

}