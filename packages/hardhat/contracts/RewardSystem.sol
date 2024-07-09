// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/////// now lets create a smart contract to manage customer purchases and reward issuance

///////// use cases Customer Purchases**: Store purchase information on the blockchain.

// - **Gift Card Issuance**: Automatically issue gift cards after a certain number of purchases











// #### 1. **Customer Tracking System**
//    - **Design Database Schema**:
//      - Create tables to store customer information, purchase history, and gift card issuance.
//      - Example schema:
//        - `Customers`: `customerId`, `name`, `email`, `phoneNumber`
//        - `Purchases`: `purchaseId`, `customerId`, `timestamp`, `amount`
//        - `GiftCards`: `cardId`, `customerId`, `tokenId`, `issueDate`
//    - **Smart Contract for Purchase Tracking**:
//      - Develop a smart contract to record each purchase on the blockchain.


contract CustomerRewards {
    struct Purchase {
        uint256 timestamp;
        uint amount;
    }

    struct GiftCard {
        uint256 balance;
        bool isActive;
        address recipient;
    }

//  ```solidity
 

    //  contract PurchaseTracker {
    //      mapping(address => uint256) public purchaseCount;

    //      event PurchaseRecorded(address indexed customer, uint256 purchaseId);

    //      function recordPurchase(address customer) public {
    //          purchaseCount[customer] += 1;
    //          emit PurchaseRecorded(customer, purchaseCount[customer]);
    //      }
    //  }
    //  ```

//       ```
//    - **Integration with Backend**:
//      - Integrate the smart contract with your backend using a service like Infura or Alchemy.
//      - Use web3.js or ethers.js to interact with the smart contract.




    mapping(address => Purchase[]) public purchases;
    mapping(uint256 => GiftCard) public giftCards;
    uint256 public giftCardCounter;

    event PurchaseRecorded(address indexed customer, uint256 amount);
    event GiftCardIssued(address indexed recipient, uint256 cardId, uint256 balance);

    function recordPurchase(uint256 amount) public {
        purchases[msg.sender].push(Purchase(block.timestamp,amount));
        emit PurchaseRecorded(msg.sender,amount);
        
        if(purchases[msg.sender].length == 2) {
            /// reward a customer after 2 purchases
            issueGiftCard(msg.sender);
        }
    }

    function issueGiftCard(address recipient) internal {
        giftCardCounter +=
        giftCards[giftCardCounter] = GiftCard(100,true,recipient);
       // emit GiftCardIssued(recipient,giftCardCounter,100)
    }

    function redeemGiftCard(uint256 cardId, uint256 amount) public {
        require(giftCards[cardId].recipient == msg.sender, "Not the owner");
        require(giftCards[cardId].isActiver, "Card is not active");
        require(giftCards[cardId].balance >= amount, "Insufficent balance");

        giftCards[cardId].balance -= amount;
        if( giftCards[cardId].balance == 0) {
            giftCards[cardId].isActive == false;
        }
    }

}









// #### 2. **Blockchain Integration for Gift Cards**
//    - **Create Custom ERC-721 Token**:
//      - Use OpenZeppelin to create an ERC-721 token that represents the gift card.


  // SPDX-License-Identifier: MIT
 pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract GiftCard is ERC721 {
    uint256 public tokenCounter;

    constructor() ERC721 ("GiftCard", G);
}






// You can organize these functions within a Solidity smart contract. Based on your requirements, it looks like you'll need a main contract to manage the creation and management of gift cards, points, stores, and users. Here’s a basic structure for how you might write these functions:

// ### Token Contract

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor() ERC20("MyToken", "MTK") {
        _mint(msg.sender, 1000000 * 10 ** decimals()); // Mint initial tokens for contract deployer
    }
}


// ### Reward and Referral Contract
// This contract will handle gift cards, points, and user/store registration.

// ```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RewardSystem is Ownable {
    ERC20 public token;

    struct GiftCard {
        uint256 id;
        address recipient;
        uint256 balance;
        bool isActive;
    }

    struct Store {
        string name;
        uint256 points;
    }

    struct User {
        string email;
        string password;
        bool isShopper;
        bool isBusinessOwner;
        uint256 totalPoints;
    }

    uint256 public giftCardCounter;
    mapping(uint256 => GiftCard) public giftCards;
    mapping(address => Store) public stores;
    mapping(address => User) public users;

    event GiftCardCreated(uint256 id, uint256 value, uint256 pointCost);
    event GiftCardAwarded(uint256 id, address recipient, uint256 balance);
    event PointsAwarded(address user, uint256 amount);

    constructor(ERC20 _token) {
        token = _token;
    }

    // Award a gift card to a recipient
    function awardGiftCard(uint256 giftCardId, address recipient) external onlyOwner {
        require(giftCards[giftCardId].isActive, "Gift card is not active");
        giftCards[giftCardId].recipient = recipient;
        emit GiftCardAwarded(giftCardId, recipient, giftCards[giftCardId].balance);
    }

    // Award points to a user
    function awardPoints(address _user, uint256 _amount) external onlyOwner {
        users[_user].totalPoints += _amount;
        emit PointsAwarded(_user, _amount);
    }

    // Create a gift card
    function createGiftCard(uint256 _value, uint256 _pointCost) external onlyOwner {
        giftCardCounter += 1;
        giftCards[giftCardCounter] = GiftCard(giftCardCounter, address(0), _value, true);
        emit GiftCardCreated(giftCardCounter, _value, _pointCost);
    }

    // Register a store
    function registerStore(string memory _name) external {
        stores[msg.sender] = Store(_name, 0);
    }

    // Register a user
    function registerUser(string memory _email, string memory _password, bool _isShopper, bool _isBusinessOwner) external {
        users[msg.sender] = User(_email, _password, _isShopper, _isBusinessOwner, 0);
    }

    // Get store points
    function getStorePoints(address _user, address _store) external view returns (uint256) {
        return stores[_store].points;
    }

    // Get total points of a user
    function getTotalPoints(address _user) external view returns (uint256) {
        return users[_user].totalPoints;
    }

    // Get gift card details
    function getGiftCard(uint256 _giftCardId) external view returns (GiftCard memory) {
        return giftCards[_giftCardId];
    }

    // Get store details
    function getStore(address _store) external view returns (Store memory) {
        return stores[_store];
    }

    // Get user details
    function getUser(address _user) external view returns (User memory) {
        return users[_user];
    }
}
// ```

// ### Explanation
// - **Token Contract:** This is a standard ERC20 token using OpenZeppelin's implementation.
// - **RewardSystem Contract:** This contract manages gift cards, points, stores, and users.
//   - **awardGiftCard:** Awards a gift card to a recipient.
//   - **awardPoints:** Awards points to a user.
//   - **createGiftCard:** Creates a new gift card.
//   - **registerStore:** Registers a new store.
//   - **registerUser:** Registers a new user.
//   - **getStorePoints:** Retrieves the points of a store.
//   - **getTotalPoints:** Retrieves the total points of a user.
//   - **getGiftCard:** Retrieves details of a gift card.
//   - **getStore:** Retrieves details of a store.
//   - **getUser:** Retrieves details of a user.

// This setup ensures a clear separation of concerns and leverages OpenZeppelin's reliable ERC20 implementation for the token functionalities. The RewardSystem contract handles the specific business logic for managing gift cards, points, stores, and users.