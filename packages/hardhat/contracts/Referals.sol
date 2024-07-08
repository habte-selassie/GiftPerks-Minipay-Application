// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReferralRewards {
    struct ReferralDetails {
        address referrer;
        bool isRewarded
    }

    struct GiftCardDetails {
        address recipient;
        uint256 balance;
        bool isActive; 
    }

    mapping(address => uint256) public purchaseCount;
    mapping(uint256 => GiftCardDetails) public giftCards;
    mapping(address => ReferralDetails) public referrals;
    uint256 public giftCardCounter;
    uiunt256 public referalRewardCounter;

     event GiftCardIssued(address indexed recipient, uint256 cardId, uint256 balance);
     event ReferralRewardIssued(address indexed referrer, uint256 cardId, uint256 balance);

      function recordPurchase(address customer) public {
        purchaseCount[customer] += 1;
        if (purchaseCount[customer] == 2) {
            issueGiftCard(customer);
        }

        if(referalls[customer].referrer != 
        address(0) && !referrals[customer].isRewarded)
        issuerReferralReward(referrals[customer].referrer)
        referrals[customer].isRewarded = true;

      }

       function issueGiftCard(address recipient) internal {
        giftCardCounter += 1;
        giftCards[giftCardCounter] = GiftCardDetails(recipient, 100, true);
        emit GiftCardIssued(recipient, giftCardCounter, 100);
    }

      function issuerReferralReward(address referrer) internal {
       giftCardCounter += 1;
       giftCards[giftCardCounter] = GiftCardDetails(referrer, 50, true);
    
    emit ReferralRewardIssued(referrer, giftCardCounter,50);

      }

      function recordReferral(address referrer, address refree) public {
        require(referrals[refree].referrer == address(0), "Referral already recorded");
        referrals[refree] = ReferralDetails(referrer,false)
      }

       function redeemGiftCard(uint256 cardId, uint256 amount) public {
        require(giftCards[cardId].recipient == msg.sender, "Not the owner");
        require(giftCards[cardId].isActive, "Card is not active");
        require(giftCards[cardId].balance >= amount, "Insufficient balance");
        giftCards[cardId].balance -= amount;
    }







}