ማኔ ቴቄል ፋሬስ (Богатство Троица), [11/07/2024 6:30 ከሰዓት]
To integrate functionalities from the GiftenMarketPlace contract into the GiftPerks contract, especially for handling purchases, subscriptions, and issuing rewards, we'll update the GiftPerks contract to interact with the GiftenMarketPlace contract. Here’s how you can modify the GiftPerks contract to incorporate these functionalities:

### Updated GiftPerks Contract with Marketplace Integration

`solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Import GiftenMarketPlace contract
import "./GiftenMarketPlace.sol";

contract GiftPerks is Ownable {
    using SafeMath for uint256;

    IERC20 public token;
    GiftenMarketPlace public marketplaceContract;

    uint256 public VIPThreshold = 1000; // Example threshold for a VIP
    uint256 public normalRewardMultiplier = 1;
    uint256 public goldRewardMultiplier = 3;
    uint256 public platinumRewardMultiplier = 5; // Increased reward for Platinum VIP

    mapping(address => uint256) public spending;
    mapping(address => bool) public isVIP;
    mapping(address => uint256) public subscriptionEndTime;

    event VIPStatusChanged(address indexed customer, bool isVIP);
    event TokensAndGiftCardsIssued(address indexed recipient, uint256 tokenAmount, uint256 giftCardAmount);
    event SubscriptionExtended(address indexed customer, uint256 endTime);

    constructor(address _tokenAddress, address _marketplaceAddress) {
        token = IERC20(_tokenAddress);
        marketplaceContract = GiftenMarketPlace(_marketplaceAddress);
    }

    function setVIPThreshold(uint256 _threshold) external onlyOwner {
        VIPThreshold = _threshold;
    }

    function spend(uint256 amount) external {
        address customer = msg.sender;
        spending[customer] = spending[customer].add(amount);
        if (!isVIP[customer] && spending[customer] >= VIPThreshold) {
            isVIP[customer] = true;
            emit VIPStatusChanged(customer, true);
        }
    }

    function revokeVIPStatus(address customer) external onlyOwner {
        isVIP[customer] = false;
        emit VIPStatusChanged(customer, false);
    }

    function issueRewards() external {
        address recipient = msg.sender;
        require(isVIP[recipient], "Recipient is not a VIP member");

        uint256 tokenAmount;
        uint256 giftCardAmount;

        // Determine reward amounts based on VIP status
        if (isVIP[recipient]) {
            if (isPlatinumVIP(recipient)) {
                tokenAmount = calculateTokenReward(platinumRewardMultiplier);
                giftCardAmount = calculateGiftCardReward(platinumRewardMultiplier);
            } else if (isGoldVIP(recipient)) {
                tokenAmount = calculateTokenReward(goldRewardMultiplier);
                giftCardAmount = calculateGiftCardReward(goldRewardMultiplier);
            }
        } else {
            // Normal user reward
            tokenAmount = calculateTokenReward(normalRewardMultiplier);
            giftCardAmount = calculateGiftCardReward(normalRewardMultiplier);
        }

        // Issue tokens and gift cards
        token.transfer(recipient, tokenAmount);
        emit TokensAndGiftCardsIssued(recipient, tokenAmount, giftCardAmount);
    }

    function calculateTokenReward(uint256 multiplier) internal pure returns (uint256) {
        // Calculate token reward based on multiplier (e.g., 1 for normal, 3 for VIP)
        return 100 * multiplier; // Example: 100 tokens per reward
    }

    function calculateGiftCardReward(uint256 multiplier) internal pure returns (uint256) {
        // Calculate gift card reward based on multiplier (e.g., 1 for normal, 3 for VIP)
        return 50 * multiplier; // Example: 50 gift card units per reward
    }

ማኔ ቴቄል ፋሬስ (Богатство Троица), [11/07/2024 6:30 ከሰዓት]
function isGoldVIP(address account) public view returns (bool) {
        // Logic to determine if account is Gold VIP
        // For demonstration, assume some condition or check against another contract
        return false;
    }

    function isPlatinumVIP(address account) public view returns (bool) {
        // Logic to determine if account is Platinum VIP
        // For demonstration, assume some condition or check against another contract
        return false;
    }

    function setTokenAddress(address _tokenAddress) external onlyOwner {
        token = IERC20(_tokenAddress);
    }

    function buyItem(uint256 _itemIndex, uint256 _pointsDiscount) external {
        // Ensure the caller is the marketplace contract
        require(msg.sender == address(marketplaceContract), "Caller is not the marketplace contract");

        // Perform buyItem logic from GiftenMarketPlace contract
        marketplaceContract.buyItem(_itemIndex, _pointsDiscount);

        // Check if buyer is VIP and issue rewards accordingly
        if (isVIP[msg.sender]) {
            issueRewards();
        }
    }

    function subscribeToVIP(uint256 _subscriptionId) external {
        // Ensure the caller is the marketplace contract
        require(msg.sender == address(marketplaceContract), "Caller is not the marketplace contract");

        // Perform subscribeToVIP logic from GiftenMarketPlace contract
        marketplaceContract.subscribeToVIP(_subscriptionId);

        // Check if subscriber is VIP and extend subscription in GiftPerks contract
        if (isVIP[msg.sender]) {
            uint256 duration = (_subscriptionId == 1) ? 6 * SECONDS_IN_MONTH : 1 * SECONDS_IN_YEAR;
            extendSubscription(msg.sender, duration);
        }
    }

    function extendSubscription(address customer, uint256 duration) internal {
        uint256 currentEndTime = subscriptionEndTime[customer];
        if (currentEndTime == 0 || currentEndTime < block.timestamp) {
            subscriptionEndTime[customer] = block.timestamp.add(duration);
        } else {
            subscriptionEndTime[customer] = currentEndTime.add(duration);
        }
        emit SubscriptionExtended(customer, subscriptionEndTime[customer]);
    }

    function checkSubscriptionStatus(address customer) external view returns (bool) {
        return subscriptionEndTime[customer] > block.timestamp;
    }
}
`

### Explanation:

1. Integration with GiftenMarketPlace Contract:
   - The `GiftPerks` contract now includes a reference to the `GiftenMarketPlace` contract (`marketplaceContract`).
   - Functions like `buyItem` and `subscribeToVIP` in `GiftPerks` delegate their functionalities to corresponding functions in `GiftenMarketPlace` while extending the subscription or issuing rewards based on the VIP status.

2. BuyItem and SubscribeToVIP Functions:
   - `buyItem`: When invoked from `GiftenMarketPlace`, it performs the purchase logic and checks if the buyer is a VIP to issue rewards accordingly.
   - `subscribeToVIP`: Similarly, when invoked from `GiftenMarketPlace`, it subscribes the user to a VIP level and extends the subscription in `GiftPerks` if the user is VIP.

3. Subscription Handling (`extendSubscription` and `checkSubscriptionStatus`):
   - `extendSubscription`: This internal function extends a customer's subscription based on the duration provided.
   - `checkSubscriptionStatus`: This function checks if a customer's subscription is active based on the `subscriptionEndTime`.

4. Reward Issuance (`issueRewards`):
   - This function issues tokens and gift cards to VIP members based on their VIP level (`normal`, `Gold`, `Platinum`).

5. VIP Status Check (`isGoldVIP` and `isPlatinumVIP`):
   - These functions provide a placeholder for determining whether an account qualifies as Gold or Platinum VIP.

ማኔ ቴቄል ፋሬስ (Богатство Троица), [11/07/2024 6:30 ከሰዓት]
6. Front-End (React) Integration:
   - In your React front-end, you'll interact primarily with GiftenMarketPlace for actions like purchasing items and subscribing to VIP levels.
   - Events emitted from these contracts (TokensAndGiftCardsIssued, SubscriptionExtended) can update the UI to reflect rewards issued and subscription status changes.

### Summary:

By integrating with the GiftenMarketPlace contract, the GiftPerks contract effectively manages VIP subscriptions, reward issuance, and subscription extensions based on purchases and subscriptions initiated through the marketplace. This setup ensures a cohesive flow between marketplace activities and VIP management, enhancing user experience and engagement within your application.

