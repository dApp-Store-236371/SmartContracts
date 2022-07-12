

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

library StringUtils {
    function len(string calldata _str) public pure returns (uint) {
        return bytes(_str).length;
    }

    function isEmpty(string memory _string) pure public returns(bool){
        return bytes(_string).length == 0;
    }

    function isNotEmpty(string memory _string) pure external returns(bool){
        return !isEmpty(_string);
    }

    function isEqual (string calldata s1, string calldata s2) pure external returns(bool){
        return keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2));
    }

    function append(string memory s1, string memory s2) pure public returns(string memory){
        return string.concat(s1, s2);
    }

    function prepend(string memory s1, string memory s2) pure public returns(string memory){
        return string.concat(s2, s1);
    }

    function getVariableMessage(string memory var_value, string memory var_name) pure external returns(string memory){
        return append(append(var_name, ": "), var_value);
    }
}