// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CUsdtToken.sol";
import "./MarketPlace.sol";
import "./GiftenToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ReferralRewards is Ownable, GiftenToken, GiftenMarketPlace {
  
    ERC20 public token;
    uint256 public userCounter;
    uint256 public referralCounter;

    struct User {
        uint256 userId;
        string name;
        string email;
        address userAddress;
        uint256 balance;
        bool hasReferred;
        bool isReferred;
        bool hasStartedTasks;
    }

    struct Referral {
        uint256 referrerId;
        uint256 refereeId;
    }

    struct Reward {
        uint256 userId;
        address recipient;
        uint256 rewardAmount;
        bool isRewarded;
    }

    mapping(uint256 => User) public users;
    mapping(address => uint256) public userAddresses;
    mapping(uint256 => uint256) public referrals; // (key: referee ID, value: referrer ID)
    mapping(uint256 => Reward) public rewards;
    mapping(uint256 => uint256) public refereeCount; // Track number of referees per referrer

    event UserAdded(uint256 indexed userId, string name, string email, address userAddress);
    event UserReferred(uint256 indexed referrerId, uint256 indexed refereeId);
    event RewardGiven(uint256 indexed userId, uint256 rewardAmount);

    constructor(ERC20 _token) {
        token = _token;
        userCounter = 0;
        referralCounter = 0;
    }

    modifier validUser(uint256 userId) {
        require(users[userId].userId != 0, "User does not exist");
        _;
    }

    modifier canRefer(uint256 referrerId, uint256 refereeId) {
        require(referrals[refereeId] == 0, "User is already referred");
        require(referrerId != refereeId, "Referrer and referee cannot be the same");
        require(!users[referrerId].hasReferred, "Referrer has already referred someone");
        _;
    }

    modifier hasStarted(uint256 refereeId) {
        require(users[refereeId].hasStartedTasks, "Referee has not started tasks in our business");
        _;
    }

    function addUser(string memory name, string memory email) public {
        userCounter++;
        users[userCounter] = User(userCounter, name, email, msg.sender, 0, false, false, false);
        userAddresses[msg.sender] = userCounter;
        emit UserAdded(userCounter, name, email, msg.sender);
    }

    function referUser(uint256 referrerId, uint256 refereeId)
        public
        validUser(referrerId)
        validUser(refereeId)
        canRefer(referrerId, refereeId)
    {
        referralCounter++;
        referrals[refereeId] = referrerId;
        users[referrerId].hasReferred = true;
        users[refereeId].isReferred = true;
        refereeCount[referrerId]++;
        emit UserReferred(referrerId, refereeId);
    }

    function rewardUser(uint256 referrerId, uint256 rewardAmount)
        public
        validUser(referrerId)
        hasStarted(referrerId)
    {
        uint256 numReferees = refereeCount[referrerId]; // Retrieve the number of referees
        require(referrerId != 0, "Referrer was not referred by any user");
        require(!rewards[referrerId].isRewarded, "Referrer has already been rewarded");

        address recipient = users[referrerId].userAddress;

        // Calculate the reward based on the number of referees
        uint256 totalRewardAmount = numReferees * rewardAmount;

        // Mint tokens to the recipient based on the reward amount
        mintGiftenToken(recipient, totalRewardAmount);

        // Update the reward record
        rewards[referrerId] = Reward(referrerId, recipient, totalRewardAmount, true);

        emit RewardGiven(referrerId, totalRewardAmount);
    }

    function startTasks(uint256 userId) public validUser(userId) {
        users[userId].hasStartedTasks = true;
    }

    function getUser(uint256 userId) public view returns (User memory) {
        return users[userId];
    }

    // 
    function getReferrals(uint256 referrerId) public view returns (uint256[] memory) {
        uint256[] memory refereeIds = new uint256[] (refereeCount[referrerId]);

         // maxReferees should be defined appropriately
         uint256 count = 0;

         // Iterate through referrals mapping to find referees of the referrer
         for (uint256 i = 0; i < refereeCount[referrerId]; i++) {
          if (referrals[i].referrerId == referrerId) {
            refereeIds[count] = referrals[i].refereeId;
            count++;
          }

           // Resize the array to the actual count of referees
           uint256 memory result = new uint256[](count);
           for (uint256 j = 0; j < count; j++) {
             result[j] = referreIds[j];
           }
            return result;
          
         }
        return
         referrals[referees] = referrals[referrer].referee;
    }

    function getRewards(uint256 userId) public view returns (Reward memory) {
        return rewards[userId];
    }
}



