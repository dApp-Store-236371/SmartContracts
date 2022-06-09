//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library Constants {
    string constant DEFAULT_EMPTY = '';
    uint constant UNRATED = 0;
    string constant DEFAULT_APP_IMAGE = 'default image';
    uint constant RATING_THRESHHOLD = 0;

}

library Events {
    event UpdatedContent(
        string indexed content_type,
        string indexed previous_content,
        string indexed new_content,
        address sender
    );

    event AppCreated(
        string indexed app_name,
        uint indexed app_id,
        address payable indexed creator,
        address sender
    );

    event UserCreated(
        address payable indexed user_address,
        address indexed user_contract,
        address sender
    );

    event UserPurchased(
        address payable indexed app_creator,
        address payable indexed buyer,
        address indexed app_contract,
        address dapp_store
    );

}

library StringUtils {
    function isEmpty(string memory _string) pure external returns(bool){
        return bytes(_string).length == 0;
    }

    function isEqual (string calldata s1, string calldata s2) pure external returns(bool){
        return keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2));
    }

    function append(string calldata s1, string calldata s2) pure external returns(string memory){
        return string(string.concat(bytes(s1), bytes(s2)));
    }

    function append(string storage s1, string calldata s2) pure external returns(string memory){
        return string(string.concat(bytes(s1), bytes(s2)));
    }
}

library AddressUtils{
    function isAddressZero(address _address) pure external returns(bool){
        return _address == address(0);
    }
    function isEqual(address _address1, address _address2) pure external returns(bool){
        return _address1 == _address2;
    }
}

library AddressPayableUtils{
    function isAddressZero(address payable _address) pure external returns(bool){
        return _address == payable(address(0));
    }
    function isEqual(address payable _address1, address payable _address2) pure external returns(bool){
        return _address1 == _address2;
    }
}



    