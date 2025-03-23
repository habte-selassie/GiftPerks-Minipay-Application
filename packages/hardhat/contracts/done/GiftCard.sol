// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

// Develop a Solidity smart contract for tracking purchases and issuing gift cards (`GiftCard.sol`).
import "./CUsdtToken.sol";
import "./MarketPlace.sol";
import "./GiftenToken.sol";

contract GiftCard is GiftenMarketPlace, GiftenToken {
    struct GiftCardDetails {
        address recipient;
        uint256 balance;
        bool isActive;
        address sender;
    }

    mapping(address => uint256) public purchaseCount; 
     //to determine the number of purchase a user made
    mapping(address => uint256) public userPoint;
    mapping (uint256 => GiftCardDetails) public giftCards;
     //a number/index to giftcard details struct
    uint256 public giftCardCounter;

    event GiftCardIssued(address indexed recipient, uint256 cardId, uint256 balance);
    event Redeemed(address indexed recipient, uint256 cardId, uint256 balance);
    event Spent(address indexed recipient, uint256 amount);

    function recordPurchase() internal {
         //implement / import a function from market place where users purchases items from shops
        purchaseCount[msg.sender] += 1;
        if (purchaseCount[msg.sender] > 2) {
        //  issueGiftCard(customer);
            userPoint[msg.sender] +=1;
        }
    }

    function buyAndBurn(uint256 _itemIndex) public {
        if(balanceOf(msg.sender) > 0) {
            buyItem(_itemIndex, balanceOf(msg.sender));
            recordPurchase();
            _burn(msg.sender, balanceOf(msg.sender));
        } else {
            buyItem(_itemIndex, 0);
            recordPurchase();
        }
    }

    function issueGiftCard(address recipient) internal {
        giftCardCounter += 1;
        giftCards[giftCardCounter] = GiftCardDetails(recipient, 100, true, msg.sender);
        emit GiftCardIssued(recipient, giftCardCounter, 100);
    }

    function redeemGiftCard() public {

        require(userPoint[msg.sender] > 0, "there is no balance");
        uint256 newBalance = userPoint[msg.sender];
        mintGiftenToken(msg.sender,newBalance);
        userPoint[msg.sender] = 0;
        purchaseCount[msg.sender] = 0;

        //transfer cusd to  recepient

        emit Redeemed(msg.sender, newBalance);
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


