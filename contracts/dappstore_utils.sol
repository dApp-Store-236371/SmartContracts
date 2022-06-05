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

}

library AddressUtils{
    function isAddressZero(address _address) pure external returns(bool){
        return _address == address(0);
    }
    function isAddressEqual(address _address1, address _address2) pure external returns(bool){
        return _address1 == _address2;
    }
}

library AddressPayableUtils{
    function isAddressZero(address payable _address) pure external returns(bool){
        return _address == payable(address(0));
    }
    function isAddressEqual(address payable _address1, address payable _address2) pure external returns(bool){
        return _address1 == _address2;
    }
}



