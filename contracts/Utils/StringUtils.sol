

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

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