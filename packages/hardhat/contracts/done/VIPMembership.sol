
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperToken.sol";
import "./VipSubscription.sol";
import "./GiftenMarketPlace.sol";

contract VipMemeberShip is Ownable {
    using SafeMath for uint256;

    ISuperfluid private _host; // Superfluid host
    ISuperToken private _cUSDToken; // Superfluid cUSD token
    GiftenMarketPlace public marketplaceContract;

    IERC20 public cusdToken;
    VipSubscription public vipSubscription;

    uint256 public VIPThreshold = 1000; // Example threshold for a VIP
    uint256 public normalRewardMultiplier = 1;
    uint256 public goldRewardMultiplier = 3;
    uint256 public platinumRewardMultiplier = 5; // Increased reward for Platinum VIP

    enum VipLevel { None, Gold, Platinum }

    struct User {
        VipLevel level;
        uint256 subscriptionTime;
        uint256 reward;
    }

    struct Item {
        uint256 price;
        address seller;
    }

    Item[] public items;

    mapping(address => uint256) public spending;
    mapping(address => User) public users;
    mapping(address => uint256) public subscriptionEndTime;

    event VIPStatusChanged(address indexed customer, bool isVIP);
    event TokensAndGiftCardsIssued(address indexed recipient, uint256 tokenAmount, uint256 giftCardAmount);
    event SubscriptionExtended(address indexed customer, uint256 endTime);
    event Subscribed(address indexed user, VipLevel level, uint256 reward);

    constructor(
        address host,
        address cUSDTokenAddress,
        address _marketplaceAddress,
        address _cusdToken,
        address _vipSubscription
    ) {
        _host = ISuperfluid(host);
        _cUSDToken = ISuperToken(cUSDTokenAddress);
        marketplaceContract = GiftenMarketPlace(_marketplaceAddress);
        cusdToken = IERC20(_cusdToken);
        vipSubscription = VipSubscription(_vipSubscription);
    }

    function setVIPThreshold(uint256 _threshold) external onlyOwner {
        VIPThreshold = _threshold;
    }

    function spend(uint256 amount) external {
        address customer = msg.sender;
        spending[customer] = spending[customer].add(amount);
        if (!isVIP(customer) && spending[customer] >= VIPThreshold) {
            users[customer].level = VipLevel.Gold; // Default to Gold VIP on reaching threshold
            emit VIPStatusChanged(customer, true);
        }
    }

    function subscribeGold() external {
        uint256 goldPrice = 20 * 10**18; // 20 cUSD
        require(_cUSDToken.transferFrom(msg.sender, address(this), goldPrice), "Payment failed");
        users[msg.sender] = User({
            level: VipLevel.Gold,
            subscriptionTime: block.timestamp,
            reward: 15 * 10**18 // 15 cUSD
        });
        _cUSDToken.transfer(msg.sender, 15 * 10**18); // Transfer reward
        emit Subscribed(msg.sender, VipLevel.Gold, 15 * 10**18);
    }

    function subscribePlatinum() external {
        uint256 platinumPrice = 35 * 10**18; // 35 cUSD
        require(_cUSDToken.transferFrom(msg.sender, address(this), platinumPrice), "Payment failed");
        users[msg.sender] = User({
            level: VipLevel.Platinum,
            subscriptionTime: block.timestamp,
            reward: 25 * 10**18 // 25 cUSD
        });
        _cUSDToken.transfer(msg.sender, 25 * 10**18); // Transfer reward
        emit Subscribed(msg.sender, VipLevel.Platinum, 25 * 10**18);
    }

    function getUserLevel(address user) public view returns (VipLevel) {
        return users[user].level;
    }

    function getDiscount(address user) public view returns (uint256) {
        if (users[user].level == VipLevel.Gold) {
            return 30; // 30% discount
        } else if (users[user].level == VipLevel.Platinum) {
            return 50; // 50% discount
        } else {
            return 0; // No discount
        }
    }

    function withdraw(uint256 amount) public onlyOwner {
        require(_cUSDToken.transfer(owner(), amount), "Withdrawal failed");
    }

    function revokeVIPStatus(address customer) external onlyOwner {
        users[customer].level = VipLevel.None;
        emit VIPStatusChanged(customer, false);
    }

    function issueRewards() external {
        address recipient = msg.sender;
        require(isVIP(recipient), "Recipient is not a VIP member");

        uint256 tokenAmount;
        uint256 giftCardAmount;

        // Determine reward amounts based on VIP status
        if (isPlatinumVIP(recipient)) {
            tokenAmount = calculateTokenReward(platinumRewardMultiplier);
            giftCardAmount = calculateGiftCardReward(platinumRewardMultiplier);
        } else if (isGoldVIP(recipient)) {
            tokenAmount = calculateTokenReward(goldRewardMultiplier);
            giftCardAmount = calculateGiftCardReward(goldRewardMultiplier);
        } else {
            // Normal user reward
            tokenAmount = calculateTokenReward(normalRewardMultiplier);
            giftCardAmount = calculateGiftCardReward(normalRewardMultiplier);
        }

        // Issue tokens and gift cards
        _cUSDToken.transfer(recipient, tokenAmount);
        emit TokensAndGiftCardsIssued(recipient, tokenAmount, giftCardAmount);
    }

    function calculateTokenReward(uint256 multiplier) internal pure returns (uint256) {
        return 100 * multiplier; // Example: 100 tokens per reward
    }

    function calculateGiftCardReward(uint256 multiplier) internal pure returns (uint256) {
        return 50 * multiplier; // Example: 50 gift card units per reward
    }

    function isVIP(address account) public view returns (bool) {
        return users[account].level != VipLevel.None;
    }

    function isGoldVIP(address account) public view returns (bool) {
        return users[account].level == VipLevel.Gold;
    }

    function isPlatinumVIP(address account) public view returns (bool) {
        return users[account].level == VipLevel.Platinum;
    }

    function buyItem(uint256 _itemId) external {
        require(_itemId < items.length, "Item does not exist");
        Item memory item = items[_itemId];

        uint256 discount = vipSubscription.getDiscount(msg.sender);
        uint256 finalPrice = item.price;
        if (discount > 0) {
            finalPrice = item.price - (item.price * discount / 100);
        }

        require(cusdToken.transferFrom(msg.sender, item.seller, finalPrice), "Payment failed");

        if (discount > 0) {
            uint256 reward = vipSubscription.users(msg.sender).reward;
            require(cusdToken.transferFrom(address(this), msg.sender, reward), "Reward transfer failed");
        }

        emit ItemBought(msg.sender, _itemId, finalPrice);
    }

    function addItem(uint256 _price) external {
        items.push(Item({ price: _price, seller: msg.sender }));
        emit ItemAdded(items.length - 1, _price, msg.sender);
    }

    function subscribeToVIP(uint256 _subscriptionId) external {
        require(msg.sender == address(marketplaceContract), "Caller is not the marketplace contract");

        marketplaceContract.subscribeToVIP(_subscriptionId);

        if (isVIP(msg.sender)) {
            uint256 duration = (_subscriptionId == 1) ? 6 * 30 days : 1 * 365 days;
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
```

This updated `GiftPerks` contract integrates the functionalities of `GiftenMarketPlace`, including item buying, VIP discounts, and reward distribution. It also retains the VIP subscription handling and Superfluid integration from the original `GiftPerks` contract.

// To implement the VIP membership subscription using Superfluid and integrate the discount and reward functionalities, we'll need to update your smart contract to:

// Use Superfluid for handling subscription payments.
// Apply discounts for VIP members when purchasing items from the marketplace.
// Issue cUSD tokens as rewards for VIP members.
// Here is the updated version of your GiftPerks contract, including the necessary modifications and integration with Superfluid:

// Updated GiftPerks Contract

