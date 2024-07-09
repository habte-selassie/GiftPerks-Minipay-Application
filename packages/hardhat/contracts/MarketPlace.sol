// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GiftenMarketPlace {

    ////// init the cusd token address

    addres public owner;

    IERC20 public cusdToken;

    struct GiftItem {
        uint256 itemId;
        uint256 itemPrice;
        string description;
        address _shop;
        bool isSold;
    }

    uint256 itemIndex;

    //// mapping 
    mapping(uint256 => GiftItem) public giftItem;
    mapping(address => bool) public isOwner;

    constructor() {
        isOwner[msg.sender] = true;
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    function createItem(uint256 _itemPrice, string memory _description) 
    public {
        uint256 index = itemIndex;
        giftItem[index] = GiftItem({
            itemId: index, itemPrice:_itemPrice, description:_description,
            isSold:false, _shop:msg.sender
        });
        itemIndex++;
    }

    function buyItem(uint256 _itemIndex, uint256 _pointsDiscount)
    public {
        require(!giftItem[_itemIndex].isSold, "item already sold");
        uint256 newAmount = (giftItem[_itemIndex].itemPrice - _pointsDiscount);

        cusdToken.transferFrom(msg.sender,address(this),newAmount);
        cusdToken.transfer(giftItem[_itemIndex]._shop,newAmount);
        giftItem[_itemIndex].isSold = true;

    }

    function addcUsdToken(address _cusdToken) public {
        cusdToken = IERC20(_cusdToken);
    }

    function setOwner(address _owner) public onlyOwner {
        isOwner[_owner] = true;
    }

    //////// get all items

    function getAllCreatedItems() public view returns (GiftItem[] memory items) {
        items = new GiftItem[](itemIndex);
        for (uint256 i = 0; i < itemIndex; i++) {
            items[i] = giftItem[i];
        }
    }



}