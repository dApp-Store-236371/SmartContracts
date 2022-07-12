//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
contract Verify is Ownable{

    function verifySignature (bytes32 message, bytes memory sig) external view returns(bool){
        address signer = recoverSigner(message, sig);
        require(signer == msg.sender, "sender is not signer");
        return true;
    }

    function recoverSigner(bytes32 message, bytes memory sig) private pure returns (address){
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig) private pure returns (uint8, bytes32, bytes32){
        require(sig.length == 65);
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }
}