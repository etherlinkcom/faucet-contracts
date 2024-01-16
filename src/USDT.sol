// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDT is ERC20 {
    address payable public owner;

    constructor(uint initialSupply) ERC20("USDT", "USDT") {
        owner = payable(msg.sender);
        _mint(owner, initialSupply * 10 ** decimals());
    }
}
