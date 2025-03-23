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
        string name;
        string description;
        address seller;
        bool isSold;
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
    mapping(uint256 => uint256) public productPrices;

    
   

    GiftItem[] public items;
    VIPSubscription[] public subscriptions;

    uint256 public itemIndex;
    uint256 public subscriptionIndex;
    uint256 public orderIndex;

    event ItemCreated(uint256 itemId, string name, uint256 itemPrice, string description, address indexed seller);
    event ItemUpdated(uint256 itemId, string name, uint256 itemPrice, string description);
    event ItemDeleted(uint256 itemId);
    event ItemPurchased(uint256 itemId, address indexed buyer, address indexed seller, uint256 itemPrice);
    event SubscriptionPurchased(address indexed user, uint256 subscriptionId, string subscriptionType, uint256 subscriptionPrice, uint256 endTime);
    event SubscriptionExpired(address indexed user, uint256 subscriptionId, string subscriptionType);
    event ItemPurchased(address indexed buyer, uint256 productId, uint256 price);


    constructor(address _cusdToken) {
        owner = msg.sender;
        cusdToken = IERC20(_cusdToken);
        isOwner[msg.sender] = true;

        // Initialize subscriptions
        subscriptions.push(VIPSubscription(0, "Normal", 0, 0, 0, true)); // Normal subscription is free
        subscriptions.push(VIPSubscription(1, "Gold", 200 * 10**18, 180 days, 0, true)); // Example: 200 cUSD for Gold, 6 months duration
        subscriptions.push(VIPSubscription(2, "Platinum", 400 * 10**18, 365 days, 0, true)); // Example: 400 cUSD for Platinum, 1 year duration
        
           // Initialize product prices (example)
        productPrices[1] = 10 ether; // Product ID 1 costs 10 CELO (in wei)
        productPrices[2] = 15 ether; // Product ID 2 costs 15 CELO (in wei)
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    modifier onlySeller(uint256 _itemId) {
        require(msg.sender == giftItems[_itemId].seller, "Not seller");
        _;
    }


    

    function purchaseItem(uint256 productId) external payable {
        require(msg.value == productPrices[productId], "Incorrect amount sent");

        // Perform actions after payment
        emit ItemPurchased(msg.sender, productId, msg.value);
    }
}


    function createItem(string memory _name, uint256 _itemPrice, string memory _description) public {
        giftItems[itemIndex] = GiftItem({
            itemId: itemIndex,
            itemPrice: _itemPrice,
            name: _name,
            description: _description,
            seller: msg.sender,
            isSold: false
        });
        items.push(giftItems[itemIndex]);
        emit ItemCreated(itemIndex, _name, _itemPrice, _description, msg.sender);
        itemIndex++;
    }

    function updateItem(uint256 _itemId, string memory _name, uint256 _itemPrice, string memory _description) public onlySeller(_itemId) {
        GiftItem storage item = giftItems[_itemId];
        item.name = _name;
        item.itemPrice = _itemPrice;
        item.description = _description;
        emit ItemUpdated(_itemId, _name, _itemPrice, _description);
    }

    function deleteItem(uint256 _itemId) public onlySeller(_itemId) {
        delete giftItems[_itemId];
        emit ItemDeleted(_itemId);
    }

    function buyItem(uint256 _itemId, uint256 _pointsDiscount) public payable {
        GiftItem storage item = giftItems[_itemId];
        require(!item.isSold, "Item already sold");
        uint256 finalPrice = item.itemPrice.sub(_pointsDiscount);

        cusdToken.transferFrom(msg.sender, item.seller, finalPrice);
        item.isSold = true;

        // Record the order
        userOrders[msg.sender].push(Order({
            orderId: orderIndex,
            itemId: _itemId,
            buyer: msg.sender,
            purchaseTime: block.timestamp,
            amountPaid: finalPrice
        }));
        orderIndex++;

        emit ItemPurchased(_itemId, msg.sender, item.seller, finalPrice);
    }

    function getItem(uint256 _itemId) public view returns (GiftItem memory) {
        return giftItems[_itemId];
    }

    function getAllItems() public view returns (GiftItem[] memory) {
        GiftItem[] memory allItems = new GiftItem[](itemIndex);
        for (uint256 i = 0; i < itemIndex; i++) {
            allItems[i] = giftItems[i];
        }
        return allItems;
    }

    function addcUsdToken(address _cusdToken) public onlyOwner {
        cusdToken = IERC20(_cusdToken);
    }

    function setOwner(address _owner) public onlyOwner {
        isOwner[_owner] = true;
    }

    function getAllSubscriptions() public view returns (VIPSubscription[] memory) {
        return subscriptions;
    }

    function subscribeToVIP(uint256 _subscriptionId) public {
        require(_subscriptionId < subscriptions.length, "Invalid subscription ID");

        VIPSubscription storage subscription = subscriptions[_subscriptionId];
        require(subscription.isActive, "Subscription is not active");

        if (keccak256(bytes(subscription.subscriptionType)) == keccak256(bytes("Normal"))) {
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


// ### Explanation

// 1. **Gift Item Management**:
//    - The contract allows creating, updating, deleting, and purchasing gift items.
//    - Each item is tracked with a unique ID, price, description, and seller address.

// 2. **VIP Subscription Management**:
//    - The contract initializes different VIP subscriptions (Normal, Gold, Platinum) with their respective prices and durations.
//    - Users can subscribe to these VIP memberships using cUSD tokens.
//    - The contract checks and updates subscription statuses, allowing users to unsubscribe or automatically expire subscriptions.

// 3. **Order Tracking**:
//    - Purchases are tracked in an `Order` struct and stored in a mapping for each user.
//    - Users can view their orders using the `getOrders` function.

// This contract provides a comprehensive solution for managing a Web3 marketplace with item listings, VIP memberships, and order tracking. You can now integrate this contract with a React front-end to allow users to interact with the marketplace.