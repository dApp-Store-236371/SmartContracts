//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

library AddressArrayUtils{
    function contains(address[] calldata array, address value) external pure returns(bool){
        for(uint i = 0; i < array.length; i++){
            if(array[i] == value){
                return true;
            }
        }
        return false;
    }

    function getIndex(address[] calldata array, address value) external pure returns(uint){
        for(uint i = 0; i < array.length; i++){
            if(array[i] == value){
                return i;
            }
        }
        return 0;
    }
}