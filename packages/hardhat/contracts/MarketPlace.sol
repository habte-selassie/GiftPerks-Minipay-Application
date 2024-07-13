
Sure, let's expand on your existing `GiftenMarketPlace` contract to include additional features for item purchasing, checkout, payment handling, order history, and item status updates. Additionally, I'll provide the corresponding React frontend code for each required page.

### Smart Contracts

I'll start by updating the `GiftenMarketPlace` contract to include the new functionalities:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract GiftenMarketPlace {
    using SafeMath for uint256;

    address public owner;
    IERC20 public cusdToken;

    struct GiftItem {
        uint256 itemId;
        uint256 itemPrice;
        string description;
        address payable _shop;
        bool isSold;
        uint256 timestamp;
    }

    struct VIPSubscription {
        uint256 subscriptionId;
        string subscriptionType; // Normal, Gold, Platinum
        uint256 subscriptionPrice;
        uint256 duration; // in seconds
        uint256 endTime; // Timestamp when subscription ends
        bool isActive;
    }

    struct Order {
        uint256 orderId;
        uint256 itemId;
        address buyer;
        uint256 purchaseTime;
        uint256 amountPaid;
    }

    mapping(uint256 => GiftItem) public giftItems;
    mapping(address => bool) public isOwner;
    mapping(address => bool) public isVIP;
    mapping(address => Order[]) public userOrders;

    GiftItem[] public items;
    VIPSubscription[] public subscriptions;

    uint256 public itemIndex;
    uint256 public subscriptionIndex;
    uint256 public orderIndex;

    event ItemCreated(uint256 itemId, uint256 itemPrice, string description, address _shop);
    event ItemBought(uint256 itemId, address buyer, uint256 amountPaid, uint256 purchaseTime);
    event SubscriptionPurchased(address indexed user, uint256 subscriptionId, string subscriptionType, uint256 subscriptionPrice, uint256 endTime);
    event SubscriptionExpired(address indexed user, uint256 subscriptionId, string subscriptionType);
    
    constructor(address _cusdToken) {
        owner = msg.sender;
        cusdToken = IERC20(_cusdToken);
        isOwner[msg.sender] = true;

        // Initialize subscriptions
        subscriptions.push(VIPSubscription(0, "Normal", 0, 0, 0, true)); // Normal subscription is free
        subscriptions.push(VIPSubscription(1, "Gold", 200 * 10**18, 180 days, 0, true)); // Example: 200 cUSD for Gold, 6 months duration
        subscriptions.push(VIPSubscription(2, "Platinum", 400 * 10**18, 365 days, 0, true)); // Example: 400 cUSD for Platinum, 1 year duration
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    function createItem(uint256 _itemPrice, string memory _description) public {
        giftItems[itemIndex] = GiftItem({
            itemId: itemIndex,
            itemPrice: _itemPrice,
            description: _description,
            _shop: payable(msg.sender),
            isSold: false,
            timestamp: block.timestamp
        });
        items.push(giftItems[itemIndex]);
        itemIndex++;
        emit ItemCreated(itemIndex, _itemPrice, _description, msg.sender);
    }

    function buyItem(uint256 _itemId, uint256 _pointsDiscount) public {
        GiftItem storage item = giftItems[_itemId];
        require(!item.isSold, "Item already sold");
        uint256 newAmount = item.itemPrice.sub(_pointsDiscount);

        cusdToken.transferFrom(msg.sender, item._shop, newAmount);
        item.isSold = true;
        
        // Record the order
        userOrders[msg.sender].push(Order({
            orderId: orderIndex,
            itemId: _itemId,
            buyer: msg.sender,
            purchaseTime: block.timestamp,
            amountPaid: newAmount
        }));
        orderIndex++;

        emit ItemBought(_itemId, msg.sender, newAmount, block.timestamp);
    }

    function addcUsdToken(address _cusdToken) public onlyOwner {
        cusdToken = IERC20(_cusdToken);
    }

    function setOwner(address _owner) public onlyOwner {
        isOwner[_owner] = true;
    }

    function getAllCreatedItems() public view returns (GiftItem[] memory) {
        return items;
    }

    function getAllSubscriptions() public view returns (VIPSubscription[] memory) {
        return subscriptions;
    }

    function subscribeToVIP(uint256 _subscriptionId) public {
        require(_subscriptionId < subscriptions.length, "Invalid subscription ID");

        VIPSubscription storage subscription = subscriptions[_subscriptionId];
        require(subscription.isActive, "Subscription is not active");

        if (subscription.subscriptionType == "Normal") {
            require(!isVIP[msg.sender], "Already subscribed to Normal VIP");
            isVIP[msg.sender] = true; // Mark user as Normal VIP
            emit SubscriptionPurchased(msg.sender, subscription.subscriptionId, subscription.subscriptionType, 0, 0);
        } else {
            uint256 subscriptionPrice = subscription.subscriptionPrice;
            require(cusdToken.balanceOf(msg.sender) >= subscriptionPrice, "Insufficient funds");

            cusdToken.transferFrom(msg.sender, address(this), subscriptionPrice);
            isVIP[msg.sender] = true; // Mark user as Gold or Platinum VIP
            subscription.endTime = block.timestamp.add(subscription.duration);
            emit SubscriptionPurchased(msg.sender, subscription.subscriptionId, subscription.subscriptionType, subscription.subscriptionPrice, subscription.endTime);
        }
    }

    function checkSubscriptionStatus(address _user) public view returns (bool) {
        for (uint256 i = 0; i < subscriptions.length; i++) {
            if (isVIP[_user] && subscriptions[i].endTime > 0 && subscriptions[i].endTime < block.timestamp) {
                isVIP[_user] = false; // Revert user to normal if subscription expired
                emit SubscriptionExpired(_user, subscriptions[i].subscriptionId, subscriptions[i].subscriptionType);
            }
        }
        return isVIP[_user];
    }

    function unsubscribeFromVIP() public {
        require(isVIP[msg.sender], "Not subscribed to VIP");

        for (uint256 i = 0; i < subscriptions.length; i++) {
            if (subscriptions[i].subscriptionType != "Normal" && subscriptions[i].endTime > 0 && subscriptions[i].endTime < block.timestamp) {
                isVIP[msg.sender] = false; // Revert user to normal if subscription expired
                emit SubscriptionExpired(msg.sender, subscriptions[i].subscriptionId, subscriptions[i].subscriptionType);
            }
        }

        isVIP[msg.sender] = false; // Mark user as non-VIP
    }

    function getOrders(address _user) public view returns (Order[] memory) {
        return userOrders[_user];
    }
}
```
/*
ማኔ ቴቄል ፋሬስ (Богатство Троица), [11/07/2024 6:15 ከሰዓት]
In the updated GiftenMarketPlace contract, I've integrated subscription handling for VIP memberships, allowing users to purchase different levels of subscriptions (Normal, Gold, Platinum) using cUSD tokens. Here's how it works:

`solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract GiftenMarketPlace {
    using SafeMath for uint256;

    address public owner;
    IERC20 public cusdToken;

    struct GiftItem {
        uint256 itemId;
        uint256 itemPrice;
        string description;
        address _shop;
        bool isSold;
    }

    struct VIPSubscription {
        uint256 subscriptionId;
        string subscriptionType; // Normal, Gold, Platinum
        uint256 subscriptionPrice;
        uint256 duration; // in seconds, for testing purpose, use 6 * 30 days for 6 months, and 365 days for 1 year
        uint256 endTime; // Timestamp when subscription ends
        bool isActive;
    }

    mapping(uint256 => GiftItem) public giftItem;
    mapping(address => bool) public isOwner;
    mapping(address => bool) public isVIP;

    GiftItem[] public items;
    VIPSubscription[] public subscriptions;

    uint256 itemIndex;
    uint256 subscriptionIndex;

    event SubscriptionPurchased(address indexed user, uint256 subscriptionId, string subscriptionType, uint256 subscriptionPrice, uint256 endTime);
    event SubscriptionExpired(address indexed user, uint256 subscriptionId, string subscriptionType);

    constructor(address _cusdToken) {
        owner = msg.sender;
        cusdToken = IERC20(_cusdToken);
        isOwner[msg.sender] = true;

        // Initialize subscriptions
        subscriptions.push(VIPSubscription(0, "Normal", 0, 0, 0, true)); // Normal subscription is free
        subscriptions.push(VIPSubscription(1, "Gold", 200 * 10**18, 180 days, 0, true)); // Example: 200 cUSD for Gold, 6 months duration
        subscriptions.push(VIPSubscription(2, "Platinum", 400 * 10**18, 365 days, 0, true)); // Example: 400 cUSD for Platinum, 1 year duration
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    function createItem(uint256 _itemPrice, string memory _description) public {
        giftItem[itemIndex] = GiftItem({
            itemId: itemIndex,
            itemPrice: _itemPrice,
            description: _description,
            _shop: msg.sender,
            isSold: false
        });
        itemIndex++;
    }

    function buyItem(uint256 _itemIndex, uint256 _pointsDiscount) public {
        require(!giftItem[_itemIndex].isSold, "Item already sold");
        uint256 newAmount = (giftItem[_itemIndex].itemPrice - _pointsDiscount);

        cusdToken.transferFrom(msg.sender, address(this), newAmount);
        cusdToken.transfer(giftItem[_itemIndex]._shop, newAmount);
        giftItem[_itemIndex].isSold = true;
    }

    function addcUsdToken(address _cusdToken) public onlyOwner {
        cusdToken = IERC20(_cusdToken);
    }

    function setOwner(address _owner) public onlyOwner {
        isOwner[_owner] = true;
    }

    function getAllCreatedItems() public view returns (GiftItem[] memory) {
        return items;
    }

    function getAllSubscriptions() public view returns (VIPSubscription[] memory) {
        return subscriptions;
    }

    function subscribeToVIP(uint256 _subscriptionId) public {
        require(_subscriptionId < subscriptions.length, "Invalid subscription ID");

        VIPSubscription storage subscription = subscriptions[_subscriptionId];
        require(subscription.isActive, "Subscription is not active");

        if (subscription.subscriptionType == "Normal") {
            require(!isVIP[msg.sender], "Already subscribed to Normal VIP");

ማኔ ቴቄል ፋሬስ (Богатство Троица), [11/07/2024 6:15 ከሰዓት]
isVIP[msg.sender] = true; // Mark user as Normal VIP
            emit SubscriptionPurchased(msg.sender, subscription.subscriptionId, subscription.subscriptionType, 0, 0);
        } else {
            uint256 subscriptionPrice = subscription.subscriptionPrice;
            require(cusdToken.balanceOf(msg.sender) >= subscriptionPrice, "Insufficient funds");

            cusdToken.transferFrom(msg.sender, address(this), subscriptionPrice);
            isVIP[msg.sender] = true; // Mark user as Gold or Platinum VIP
            subscription.endTime = block.timestamp.add(subscription.duration);
            emit SubscriptionPurchased(msg.sender, subscription.subscriptionId, subscription.subscriptionType, subscription.subscriptionPrice, subscription.endTime);
        }
    }

    function checkSubscriptionStatus(address _user) public view returns (bool) {
        for (uint256 i = 0; i < subscriptions.length; i++) {
            if (isVIP[_user] && subscriptions[i].endTime > 0 && subscriptions[i].endTime < block.timestamp) {
                isVIP[_user] = false; // Revert user to normal if subscription expired
                emit SubscriptionExpired(_user, subscriptions[i].subscriptionId, subscriptions[i].subscriptionType);
            }
        }
        return isVIP[_user];
    }

    function unsubscribeFromVIP() public {
        require(isVIP[msg.sender], "Not subscribed to VIP");

        for (uint256 i = 0; i < subscriptions.length; i++) {
            if (subscriptions[i].subscriptionType != "Normal" && subscriptions[i].endTime > 0 && subscriptions[i].endTime < block.timestamp) {
                isVIP[msg.sender] = false; // Revert user to normal if subscription expired
                emit SubscriptionExpired(msg.sender, subscriptions[i].subscriptionId, subscriptions[i].subscriptionType);
            }
        }

        isVIP[msg.sender] = false; // Mark user as non-VIP
    }
}
`

### Explanation

1. Subscription Management:
   - VIPSubscription Struct: Defines a structure to manage different subscription types (`Normal`, `Gold`, `Platinum`). Each subscription has an ID, type, price, duration, end time, and active status.
   - subscriptions Array: Stores predefined subscription types and their details, initialized in the constructor.

2. Subscription Purchase:
   - subscribeToVIP Function: Allows users to subscribe to a VIP membership by specifying the subscription ID (`_subscriptionId`). Depending on the subscription type:
     - Normal: Marks the user as a Normal VIP without any payment.
     - Gold or Platinum: Requires the user to transfer the subscription price in cUSD tokens to the contract. Updates the user's VIP status and sets an end time for the subscription.

3. Subscription Status and Expiry:
   - checkSubscriptionStatus Function: Checks if the user's VIP subscription has expired based on the current block timestamp (`block.timestamp`). If expired, reverts the user's VIP status to Normal and emits an `SubscriptionExpired` event.

4. Unsubscribe from VIP:
   - unsubscribeFromVIP Function: Allows users to unsubscribe from their current VIP membership, reverting their status to Normal.

### Next Steps

- Testing: Thoroughly test the contract to ensure all functionalities work as expected, including subscription purchase, status checks, and expiration handling.
  
- Front-End Integration: Implement a React front-end to interact with this contract, allowing users to view available subscriptions, purchase memberships, and check their VIP status.

This setup provides a foundation for managing VIP memberships and integrating them with a marketplace where VIP users can access exclusive benefits such as discounts and rewards based on their subscription level. Adjustments may be needed based on specific project requirements and additional features you plan to implement.
