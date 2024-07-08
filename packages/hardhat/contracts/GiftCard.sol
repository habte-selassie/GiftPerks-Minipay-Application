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


    event giftCardIssued(address indexed recipient, uint256 cardId, 
    uint256 balance);

    function recordPurchase(address customer) public {
        purchaseCount[customer] = purchaseCount[customer] + 1;
        if(purchaseCount[customer] == 2) {
            issueGiftCard(customer);
        }
    }

        function issueGiftCard(address recipient) internal {
            giftCardCounter = giftCardCounter + 1;
            giftCards[giftCardCounter] = 
            GiftCardDetails(recipient, 100, true, sender);

            emit GiftCardIssued(recipeint, giftCardCounter,100)

        }

        function redeemGiftCard(uint256 cardId, uint256 amount) public {
            require(giftCards[cardId].recipient == msg.sender, 
            "Not the owner");
            require(giftCards[cardId].isActive, "Card is not active");
            require(giftCards[cardId].balance >= amount, "Insufficient balance");
            giftCards[cardId].balance -= amount
        }



        event Redeemed(address indexed recipient, uint256 cardId, 
    uint256 balance);
    event Spent(address indexed recipient, uint256 amount)

    function issue(bytes32 hash, uint256 value) public {
        require(condition);
    }
      
    }


pragma solidity ^0.5.0;

contract Giftcards {
	address public owner;

	struct Giftcard {
		address owner;
		uint value;
	}

	mapping (address => uint) balances;
	mapping (bytes32 => Giftcard) giftcards;

	event Redeemed(address indexed _by, bytes32 _hash);
	event Spent(address indexed _by, uint _amount);

	constructor() public {
		owner = msg.sender;
	}

	function issue(bytes32 hash, uint value) public {
		require(msg.sender == owner, "Only the owner can issue new giftcards");
		require(value > 0, "Giftcard must have a balance");
		require(giftcards[hash].value == 0, "Giftcard already issued");

		giftcards[hash] = Giftcard({
			value: value,
			owner: address(0) // No owner
		});
	}

	function redeem(bytes memory code) public {
		bytes32 hash = keccak256(code);
		Giftcard memory giftcard = giftcards[hash];

		require(giftcard.value > 0, "Invalid giftcard code");
		require(giftcard.owner == address(0), "Giftcard already redeemed");

		giftcards[hash].owner = msg.sender;
		balances[msg.sender] += giftcard.value;

		emit Redeemed(msg.sender, hash);
	}

	function spend(address by, uint amount) public {
		require(msg.sender == owner, "Only the owner can deduct from balance");

		uint balance = balances[by];

		require(balance >= amount, 'Insufficient funds');

		balances[by] -= amount;

		emit Spent(by, amount);
	}

	function getBalance() public view returns (uint _balance) {
		_balance = balances[msg.sender];
	}
}