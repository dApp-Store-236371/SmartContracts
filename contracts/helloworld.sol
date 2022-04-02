pragma solidity ^0.4.22;

contract HelloWorld {
    string public message;

    constructor() public {
        message = "first";
    }

    function setMessage(string newMessage) public {
        message = newMessage;
    }

    function remove() public {
        selfdestruct(0x0);
    }
}