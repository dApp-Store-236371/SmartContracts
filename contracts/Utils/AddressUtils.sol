//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

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