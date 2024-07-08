// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract TokenManager is Ownable {
    IERC20 public token;

    mapping(address => uint256) public tokenBalance;

    event TokensIssued(address indexed recipient, uint256 amount);
    event TokensRedeemed(addres indexed recippient, uint256 amount);

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress)
    }

    function issueTokens(address recipient, uint256 amount) external onlyOwner {
        tokenBalance[recipient] += amount;
        emit TokensIssued(recipient, amount);
    }

    function redeemTokens(uint256 amount) external {
        require(tokenBalance[msg.sender] >= amount, "Insufficent balance");
        tokenBalance[msg.sender] -= amount;
        token.transfer(msg.sender, amount);
        emit TokensRedeemed(recippient, amount);
    }

     function setTokenAddress(address _tokenAddress) external onlyOwner {
        token = IERC20(_tokenAddress);
    }

}