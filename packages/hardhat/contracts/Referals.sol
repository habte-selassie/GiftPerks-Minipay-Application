// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CUsdtToken.sol";
import "./MarketPlace.sol";
import "./GiftenToken.sol";

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";


contract ReferralRewards is Ownable, GiftenToken,GiftenMarketPlace {
 
 
    ERC20 public token;

    
    struct User {
      uint256 userId;
      string name;
      string email;
      address userAddress;
      uint256 balance;
      bool hasReferred;
      bool isReferred;  
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

   

// ### Referral Contract
// This contract will handle gift cards, points, and user/store registration.
    
    mapping (uint256 => User) users;
    mapping (address => uint256) referCount;
    mapping (uint256 => uint256) referrals; //// used to map refrees Id to referrers Id
    /// like this  (key: referee ID, value: referrer ID)
    mapping (uint256 => Reward) rewards;
    mapping(uint256 => uint256) public refereeCount; // Track number of referees per referrer
    mapping(uint256 => uint256) public balances; // To track user balances
    mapping(uint256 => bool) public hasStartedTasks; // key: user ID, value: mining status
   // uint256 public referalCounter;
   

    //////// events 
    event UserAdded(uint256 indexed userId,string name, string email, string );
    event UserReferred(uint256 indexed referrerId, uint256 indexed refereeId);
    event RewardGiven(uint256 indexed userId, uint256 rewardAmount);

   
    
    constructor(ERC20 _token) {
        token = _token;
    }

    //////// modifiers
    modifier validUser(uint256 userId) {
      require(users[userId].userId != 0, " User Does not exist");
      _;
    }

    modifier canRefer(uint256 referrerId, uint256 refereeId){
      require(referrals[refereeId].refereeId == 0, "user is already referred");
      require(referrerId != refereeId,"Referrer and Referee can not be the same");
      require(!users[referrerId].hasReferred,"Referrer has already referred someone");
      _;
    }

    modifier hasStarted(uint256 refereeId) {
      require(hasStartedTasks[refereeId],"Referee has not started tasks in our business");
      _;
    }

    function addUser(uint256 userId, string memory name, string memory email) public {
      users[userId] = User(userId, name, email,msg.sender, 0, false, false);
      emit userAdded(userId, name, email);
    }

    // Function to record a referral
    function recordReferral(address referrer, address referee) public {
    // Check if the referee's referral is already recorded
    require(!referrals[referee].isActive, "Referral already recorded");
    // Record the referral
    referrals[referee] = Referral(referrer, true);
}

    function referUser(uint256 referrerId, uint256 refereeId)
     public validUser(referrerId) validUser(refereeId) 
     canRefer(referrerId, refereeId) {
      referrals[refereeId] = Referral(referrerId, refereeId);
      users[referrerId].hasReferred = true;
      users[refereeId].isReferred = true;
      refereeCount[referrerId]++;
      emit UserReferred(referrerId, refereeId);
     
    }

  function rewardUser(uint256 referrerId, uint256 _rewardAmount)
   public validUser(referrerId) hasStarted(referrerId) {
    uint256 refereeCount = refereeCount[referrerId]; // Retrieve the number of referees
    require(referrerId != 0, "Referrer was not referred by any user");
    require(!rewards[referrerId].isRewarded, "Referrer has already been rewarded");

    address recipient = users[referrerId].userAddress;
    
    // Calculate the reward based on the number of referees
    uint256 rewardAmount = refereeCount * _rewardAmount;
    
    // Mint tokens to the recipient based on the reward amount
    mintGiftenToken(recipient, rewardAmount);

    // Update the reward record
    rewards[referrerId] = Reward(referrerId, recipient, rewardAmount, true);

    emit RewardGiven(referrerId, rewardAmount);

    rewards[referrerId].isRewarded = true;
}

   




    function startTasks(uint256 userId) public validUser(userId){
      users[userId].hasStartedTasks = true;
    }

     // Get user details
    function getUser(uint256 userId) public view returns (User memory) { 
      return  users[userId];    
    }

     // Get gift card details
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
    

     // Get reward details for a user
     function getRewards(uint256 userId) public view returns (Reward memory) {
       return rewards[userId];
      }


   
}

    


