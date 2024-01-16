// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Faucet {
    event Drip(address indexed _token, address indexed _to, uint _dripAmount);
    event Withdrawal(address indexed _token, address indexed _from, uint _amount);

    address payable owner;

    mapping(address => mapping(address => uint)) nextAccessTime;
    uint public lockTime = 1 minutes; // to be replaced by 24h with SetLockTime()

    constructor() {
        owner = payable(msg.sender);
    }

    function requestTokens(address tokenAddress, address claimAddress) public {
        require(msg.sender == owner, "Request must originate from owner.");

        uint dripAmount = 10 * (10**18);
        IERC20 token = IERC20(tokenAddress);

        require(token.balanceOf(address(this)) >= dripAmount, "Faucet is dry.");
        require(block.timestamp >= nextAccessTime[claimAddress][tokenAddress], "Insufficient time elapsed since last drip.");

        bool success = token.transfer(claimAddress, dripAmount);

        if (success)
            emit Drip(tokenAddress, claimAddress, dripAmount);
            nextAccessTime[claimAddress][tokenAddress] = block.timestamp + lockTime;
    }

    receive() external payable {
    }

    function setLockTime(uint _numberOfHours) public onlyOwner {
        require(msg.sender == owner, "Only the owner can change the lock time.");
        lockTime = _numberOfHours * 1 hours;
    }

    function withdraw(address _tokenAddress) external onlyOwner {
        require(msg.sender == owner, "Only the owner can withdraw the contract balance.");

        IERC20 token = IERC20(_tokenAddress);
        require(token.balanceOf(address(this)) > 0, "Insufficient balance.");
        token.transfer(owner, token.balanceOf(address(this)));

        emit Withdrawal(_tokenAddress, msg.sender, token.balanceOf(address(this)));
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
        }
}