//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {App} from '../Apps/App.sol';
import {User} from './User.sol';
import {Constants} from '../Utils/Constants.sol';
import {StringUtils} from '../Utils/StringUtils.sol';
import {AddressUtils, AddressPayableUtils} from '../Utils/AddressUtils.sol';
import {AppInfoLibrary} from '../Utils/AppInfoLibrary.sol';

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

contract UserManager is Ownable{

}