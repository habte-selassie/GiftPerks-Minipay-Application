// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

// Develop a Solidity smart contract for tracking purchases and issuing gift cards (`GiftCard.sol`).

contract GiftCard {
    struct GiftCardDetails {
        address recipient;
        uint256 balance;
        bool isActive;
        address sender;
    }

    mapping(address => uint256) public purchaseCount;
    mapping (uint256 => GiftCardDetails) public giftCards;
    uint256 public giftCardCounter;

    event GiftCardIssued(address indexed recipient, uint256 cardId, uint256 balance);
    event Redeemed(address indexed recipient, uint256 cardId, uint256 balance);
    event Spent(address indexed recipient, uint256 amount);

    function recordPurchase(address customer) public {
        purchaseCount[customer] += 1;
        if (purchaseCount[customer] == 2) {
            issueGiftCard(customer);
        }
    }

    function issueGiftCard(address recipient) internal {
        giftCardCounter += 1;
        giftCards[giftCardCounter] = GiftCardDetails(recipient, 100, true, msg.sender);
        emit GiftCardIssued(recipient, giftCardCounter, 100);
    }

    function redeemGiftCard(uint256 cardId, uint256 amount) public {
        require(giftCards[cardId].recipient == msg.sender, "Not the owner");
        require(giftCards[cardId].isActive, "Card is not active");
        require(giftCards[cardId].balance >= amount, "Insufficient balance");
        giftCards[cardId].balance -= amount;
        emit Redeemed(msg.sender, cardId, giftCards[cardId].balance);
    }

    function issue(bytes32 hash, uint256 value) public {
        require(msg.sender == owner, "Only the owner can issue new giftcards");
        require(value > 0, "Giftcard must have a balance");
        require(giftCards[uint256(hash)].balance == 0, "Giftcard already issued");

        giftCardCounter += 1;
        giftCards[giftCardCounter] = GiftCardDetails({
            recipient: address(0), // No owner yet
            balance: value,
            isActive: true,
            sender: msg.sender
        });

        emit GiftCardIssued(address(0), giftCardCounter, value);
    }

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function spend(address by, uint amount) public {
        require(msg.sender == owner, "Only the owner can deduct from balance");
        require(giftCards[uint256(by)].balance >= amount, "Insufficient funds");

        giftCards[uint256(by)].balance -= amount;

        emit Spent(by, amount);
    }

    function getBalance(uint256 cardId) public view returns (uint256 balance) {
        return giftCards[cardId].balance;
    }
}


