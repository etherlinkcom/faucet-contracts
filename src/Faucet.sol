// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Faucet {
    event Drip(address indexed _token, address indexed _to, uint _dripAmount);
    event Withdrawal(address indexed _token, address indexed _from, uint _amount);

    address payable owner;

    mapping(address => mapping(address => uint)) nextAccessTime;
    uint public lockTime = 1 minutes; // to be replaced by 24h with SetLockTime()
    address private wxtz = 0xB1Ea698633d57705e93b0E40c1077d46CD6A51d8;
    address private eusd = 0x1A71f491fb0Ef77F13F8f6d2a927dd4C969ECe4f;
    address private usdt = 0xD21B917D2f4a4a8E3D12892160BFFd8f4cd72d4F;
    address private usdc = 0xa7c9092A5D2C3663B7C5F714dbA806d02d62B58a;
    address private weth = 0x8DEF68408Bc96553003094180E5C90d9fe5b88C1;
    address private tzbtc = 0x6bDE94725379334b469449f4CF49bCfc85ebFb27;

    constructor() {
        owner = payable(msg.sender);
    }

    function drip(address tokenAddress, address claimAddress) public {
        uint dripAmount;
        ERC20 token = ERC20(tokenAddress);
        if (tokenAddress == wxtz){
            dripAmount = 1 * (10**token.decimals());
        }
        else if (tokenAddress == eusd){
            dripAmount = 10 * (10**token.decimals());
        }
        else if (tokenAddress == usdt){
            dripAmount = 10 * (10**token.decimals());
        }
        else if (tokenAddress == usdc){
            dripAmount = 10 * (10**token.decimals());
        }
        else if (tokenAddress == weth){
            dripAmount = 1 * (10**(token.decimals() - 1));
        }
        else if (tokenAddress == tzbtc){
            dripAmount = 1 * (10**(token.decimals() - 1));
        }
        else{
            dripAmount = 1 * (10**token.decimals());
        }

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