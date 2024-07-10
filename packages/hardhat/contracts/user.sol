
 // Get store details
    function getStore(address _store) external view returns (Store memory) {
        return stores[_store];
    }

  
    // Award points to a user
    function awardPoints(address _user, uint256 _amount) external onlyOwner {
        users[_user].totalPoints += _amount;
        emit PointsAwarded(_user, _amount);
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

    
    // Get store details
    function getStore(address _store) external view returns (Store memory) {
        return stores[_store];
    }

   
}

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

      function issuerReferralReward(address referrer) internal {
       giftCardCounter += 1;
       giftCards[giftCardCounter] = GiftCardDetails(referrer, 50, true);
    
    emit ReferralRewardIssued(referrer, giftCardCounter,50);

      }

      function recordReferral(address referrer, address refree) public {
        require(referrals[refree].referrer == address(0), "Referral already recorded");
        referrals[refree] = ReferralDetails(referrer,false)
      }

       



//////////// later used for user role in project

//  struct user_data {
//         string email;
//         string password;
//         bool isShopper;
//         bool isBusinessOwner;
//         uint256 totalPoints;
//     }

}




















   

















 // Get store details
    function getStore(address _store) external view returns (Store memory) {
        return stores[_store];
    }

  
    // Award points to a user
    function awardPoints(address _user, uint256 _amount) external onlyOwner {
        users[_user].totalPoints += _amount;
        emit PointsAwarded(_user, _amount);
    }

    
    // Register a store
    function registerStore(string memory _name) external {
        stores[msg.sender] = Store(_name, 0);
    }

    
    // Get store points
    function getStorePoints(address _user, address _store) external view returns (uint256) {
        return stores[_store].points;
    }

    // Get total points of a user
    function getTotalPoints(address _user) external view returns (uint256) {
        return users[_user].totalPoints;
    }

    
    // Get store details
    function getStore(address _store) external view returns (Store memory) {
        return stores[_store];
    }

   