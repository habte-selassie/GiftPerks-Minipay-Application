// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract VIPMembership is Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) public spending;
    mapping(address => bool) public isVIP;

    uint256 public VIPThreshold = 1000; ///// example thershold for a vip

    event VIPStatusChanged(address indexed customer, bool isVIP);

    function setVIPThreshold(uint256 _threshold) external onlyOwner {
        VIPThreshold = _threshold;
    }

    function spend(address customer, uint256 amount) external {
        spending[customer] = spending[customer].add(amount)
        if(!isVIP[customer] && spending[customer] >= VIPThreshold){
            isVIP[customer] = true;
            emit VIPStatusChanged(customer, true);
        }
    }

    function revokeVIPStatus(address customer) external onlyOwner {
        isVIP[customer] = false;
        emit VIPStatusChanged(customer, false);
    }


}

