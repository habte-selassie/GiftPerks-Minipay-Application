// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VIPRewards is Ownable {
    IERC20 public token;

    mapping(address => bool) public isVIP;

    event RewardsIssued(address indexed recipient, uint256 amount);

    constructor (address _tokenAddress) {
        token = IERC20(_tokenAddress)
    }

    function issuerRewarded(address recipient, uint256 amount) external onlyOwner {
        require(isVIP[recipient], "Recipeint is not a VIP member");
        token.transfer(recipient, amount);
        emit RewardsIssued(recipient, amount);
    }

    function setTokenAddress(address _tokenAddress) external onlyOwner {
        token = IERC20(_tokenAddress)
    }
}