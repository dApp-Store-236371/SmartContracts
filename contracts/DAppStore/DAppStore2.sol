//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;
import {User} from '../Users/User.sol';
import {App} from '../Apps/App.sol';
import {Constants} from '../Utils/Constants.sol';
import {StringUtils} from '../Utils/StringUtils.sol';
import {AddressUtils, AddressPayableUtils} from '../Utils/AddressUtils.sol';
import {Events} from '../Utils/Events.sol';
import {AppInfoLibrary} from '../Utils/AppInfoLibrary.sol';
import {UserManager} from '../Users/UserManager.sol';
import {AppManager} from '../Apps/AppManager.sol';
import {Verify} from '../Utils/SignatureVerifier.sol';

import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";



contract DAppStore{
    using StringUtils for string;
    using AddressUtils for address;
    using AddressPayableUtils for address payable;
    using Strings for uint;

    UserManager private userManager;
    AppManager private appManager;
    Verify private verifier;
    uint private key_length = 32;
    string constant random_string = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    // events

    //modifiers
    modifier onlyRegistered(){
        require(!msg.sender.isAddressZero(), "Invalid user address");
        require(userManager.userExists(), "User not registered");
        _;
    }

    modifier isAppOwner(uint _app_id){
        address _app_address = address(appManager.getAppAddress(_app_id));
        require(userManager.isUserAppOwner(_app_address), "User is not app owner");
        _;
    }

    modifier isAppCreator(uint _app_id){
        address _app_address = address(appManager.getAppAddress(_app_id));
        require(userManager.isUserAppCreator(_app_address), "User is not app creator");
        _;
    }

    modifier verifySignature(string memory message, string calldata signature){
        // bytes message_bytes = bytes(message);
        require(message.len() <= 32 && message.len() > 0, "Message is empty");
        require(verifier.verifySignature(message, signature), "Invalid signature");
        _;
    }

    constructor(){
        userManager = new UserManager();
        appManager = new AppManager();
        verifier = new Verify();
    }
    
    function createNewApp(
        string memory _name,
        string memory _description,
        string memory _magnetLink,
        string memory _imgUrl,
        string memory _company,
        uint _price,
        string memory _category,
        string memory _fileSha256,
        string calldata _message,
        string calldata _signature
    ) public
    onlyRegistered
    verifySignature(_message, _signature){
        appManager.createNewApp(
            _name, 
            _description, 
            _magnetLink, 
            _imgUrl, 
            _company, 
            _price, 
            _category, 
            _fileSha256
        );
        address new_app = appManager.getAppAddress(appManager.getAppCount() - 1);
        userManager.createNewApp(new_app);
    }

    function updateApp(
        uint app_id,
        string memory _name,
        string memory _description,
        string memory _magnetLink,
        string memory _imgUrl,
        uint _price,
        string memory _fileSha256,
        string calldata _message,
        string calldata _signature
    ) external 
      onlyRegistered
 
      isAppCreator(app_id)
      verifySignature(_message, _signature){
        appManager.updateApp(app_id, _name, _description, _magnetLink, _imgUrl, _price, _fileSha256);
    }

    function purchaseApp(uint app_id, 
    string calldata _message, 
    string calldata _signature
    ) external 
      payable
      onlyRegistered
 
      verifySignature(_message, _signature){ 
        address _app_address = appManager.getAppAddress(app_id);
        require(userManager.isUserAppOwner(_app_address), "Can't buy app twice");
        // App app = App(app_address);
        (bool sent,) = appManager.getAppCreator(app_id).call{value: msg.value}(""); //sends ether to the creator
        require(sent, "Failed to send Ether");
        userManager.markAppAsPurchased(_app_address);
    }

    function getAppBatch(uint start, uint len, string calldata _message, string calldata _signature) 
    view 
    external 
    onlyRegistered
    verifySignature(_message, _signature)
    returns( AppInfoLibrary.AppInfo[] memory){
        return appManager.getAppBatch(start, len);
    }

    function registerUser(string calldata _message, string calldata _signature) 
    external 
    verifySignature(_message, _signature){
        string memory key = block.timestamp.toString();
        userManager.createUser(key);
    }
    
    function getMessageToSign() external view returns (string memory){
        string memory message = '';
        for (uint i = 0; i < key_length; i++){
            string memory rnd_index = uint(block.timestamp % 10).toString();
            message = message.append(rnd_index);
        }
        return message;
    }

    
    function getPurchasedAppsInfo(string calldata _message, string calldata _signature) 
    external 
    view 
    onlyRegistered
    verifySignature(_message, _signature)
    returns(AppInfoLibrary.AppInfo[] memory){
        return userManager.getPurchasedAppsInfo();
    }

    function getPublishedAppsInfo(string calldata _message, string calldata _signature) 
    external 
    view 
    onlyRegistered
    verifySignature(_message, _signature)
    returns(AppInfoLibrary.AppInfo[] memory){
        return userManager.getPublishedApps();
    }

    function getRatedAppsInfo(string calldata _message, string calldata _signature) 
    external 
    view 
    onlyRegistered
    verifySignature(_message, _signature) 
    returns(AppInfoLibrary.AppInfo[] memory){
        return userManager.getRatedApps();
    }

    function getAppCount() view external returns(uint){
        return appManager.getAppCount();
    }


    function rateApp(uint _app_id, 
                     uint new_rating, 
                     string calldata _message, 
                     string calldata _signature
    ) external
      onlyRegistered
      verifySignature(_message, _signature){
        address _app_address = appManager.getAppAddress(_app_id);
        uint old_rating = userManager.getUserRating(_app_address);
        appManager.rateApp(_app_id, new_rating, old_rating);
        userManager.markAppAsRated(_app_address, new_rating);
    }

}