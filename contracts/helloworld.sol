pragma solidity ^0.8.13;

contract HelloWorld {
    string public message;

    constructor() public {
        message = "first";
    }

    function setMessage(string memory newMessage) public {
        message = newMessage;
    }
}