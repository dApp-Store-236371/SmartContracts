pragma solidity ^0.8.0;

library dappstore_utils {
    string constant DEFAULT_EMPTY = '';
    uint constant UNRATED = 0;
    string constant DEFAULT_APP_IMAGE = '';
    uint constant RATING_THRESHHOLD = 0;


    event UpdatedContent(
        string indexed content_type,
        string indexed previous_content,
        string indexed new_content,
        address sender
    );
}

