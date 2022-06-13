//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

library Constants {
    string constant DEFAULT_EMPTY = '';
    uint constant UNRATED = 0;
    string constant DEFAULT_APP_IMAGE = 'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fi.pinimg.com%2Foriginals%2F20%2F0e%2Ff8%2F200ef82b3182ff75bf0b2de5496e61cf.jpg&f=1&nofb=1';
    string constant DEFAULT_APP_MAGNET_LINK = 'magnet:?xt=urn:btih:08ada5a7a6183aae1e09d831df6748d566095a10&dn=Sintel&tr=udp%3A%2F%2Fexplodie.org%3A6969&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Ftracker.empire-js.us%3A1337&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337&tr=wss%3A%2F%2Ftracker.btorrent.xyz&tr=wss%3A%2F%2Ftracker.fastcast.nz&tr=wss%3A%2F%2Ftracker.openwebtorrent.com&ws=https%3A%2F%2Fwebtorrent.io%2Ftorrents%2F&xs=https%3A%2F%2Fwebtorrent.io%2Ftorrents%2Fsintel.torrent';
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
        address dapp_store
    );

    event UserCreated(
        address payable indexed user_address,
        address indexed user_contract,
        address dapp_store
    );

    event UserPurchasedApp(
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
        return string.concat(s1, s2);
    }

    function prepend(string calldata s1, string calldata s2) pure external returns(string memory){
        return string.concat(s2, s1);
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



