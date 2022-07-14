
const sha3 = require('js-sha3').keccak_256;
const keccak256 = require('keccak256');
var chai = require("chai");
const expect = chai.expect;
const assert = chai.assert;
let catchRevert = require("./exceptions.js").catchRevert;


const {
    BN,           // Big Number support
    constants,    // Common constants, like the zero address and largest integers
    expectEvent,  // Assertions for emitted events
    expectRevert, // Assertions for transactions that should fail
  } = require('@openzeppelin/test-helpers');

const AppManager = artifacts.require("AppManager");
const UserManager = artifacts.require("UserManager");

// Start test block
contract('App contract', function () {
   
  });