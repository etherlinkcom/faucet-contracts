// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Faucet} from "../src/Faucet.sol";
import {USDC} from "../src/USDC.sol";

contract FaucetTest is Test {
    Faucet public faucet;
    USDC public usdc;
    uint public initialSupply;

    function setUp() public {
        faucet = new Faucet();
        initialSupply = 1000;
        usdc = new USDC(initialSupply);
        usdc.transfer(address(faucet), initialSupply * (10**usdc.decimals()));
    }

    function test_drip() public {
        uint expectedDripAmount = 1 * (10**usdc.decimals());
        faucet.drip(address(usdc), address(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84));
        assertEq(usdc.balanceOf(address(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84)), expectedDripAmount);
    }

    function test_withdraw() public {
        faucet.withdraw(address(usdc));
        assertEq(usdc.balanceOf(address(faucet)), 0);
    }

    function testFail_drip() public {
        faucet.withdraw(address(usdc));
        faucet.drip(address(usdc), address(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84));
    }
}