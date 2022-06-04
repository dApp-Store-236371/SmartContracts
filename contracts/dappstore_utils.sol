pragma solidity ^0.8.0;

library constants {
    string constant DEFAULT_EMPTY = '';
    uint constant UNRATED = 0;
    string constant DEFAULT_APP_IMAGE = 'default image';
    uint constant RATING_THRESHHOLD = 0;

}

library events{
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
}

library string_utils{
    function isEmpty(string memory _string) pure external returns(bool){
        return bytes(_string).length == 0;
    }

}

