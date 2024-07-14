### Front-End (React)

#### 1. Install dependencies

Make sure you have the following dependencies installed:
sh
npm install web3 @openzeppelin/contracts axios

#### 2. Referral System Component

Create a new component called `ReferralSystem.js`:

javascript
import React, { useState, useEffect } from 'react';
import Web3 from 'web3';
import axios from 'axios';
import ReferralRewardsABI from './ReferralRewardsABI.json';

const ReferralSystem = () => {
    const [account, setAccount] = useState('');
    const [referrals, setReferrals] = useState([]);
    const [copySuccess, setCopySuccess] = useState('');

    useEffect(() => {
        loadBlockchainData();
    }, []);

    const loadBlockchainData = async () => {
        const web3 = new Web3(Web3.givenProvider || 'http://localhost:8545');
        const accounts = await web3.eth.requestAccounts();
        setAccount(accounts[0]);

        const contractAddress = 'YOUR_CONTRACT_ADDRESS';
        const referralRewards = new web3.eth.Contract(ReferralRewardsABI, contractAddress);

        const userId = await referralRewards.methods.userAddresses(accounts[0]).call();
        const referralsArray = await referralRewards.methods.getReferrals(userId).call();

        const referralData = [];
        for (let i = 0; i < referralsArray.length; i++) {
            const user = await referralRewards.methods.getUser(referralsArray[i]).call();
            const reward = await referralRewards.methods.getRewards(referralsArray[i]).call();
            referralData.push({
                name: user.name,
                reward: reward.rewardAmount,
            });
        }
        setReferrals(referralData);
    };

    const copyToClipboard = () => {
        navigator.clipboard.writeText(http://yourapp.com/signup?ref=${account}).then(() => {
            setCopySuccess('Copied!');
            setTimeout(() => setCopySuccess(''), 3000);
        });
    };

    const sendInvite = async (email) => {
        try {
            await axios.post('http://yourbackend.com/send-invite', { email, referrer: account });
        } catch (error) {
            console.error('Error sending invite', error);
        }
    };

    return (
        <div>
            <div className="invite-card">
                <h2>Invite a Friend</h2>
                <input
                    type="email"
                    placeholder="Enter friend's email"
                    id="inviteEmail"
                />
                <button onClick={() => sendInvite(document.getElementById('inviteEmail').value)}>Invite or Refer a Friend</button>
                <button onClick={copyToClipboard}>
                    Copy Link <i className="copy-icon"></i>
                </button>
                {copySuccess && <p>{copySuccess}</p>}
            </div>

            <div className="friends-list">
                <h2>Your Friends List</h2>
                <table>
                    <thead>
                        <tr>

ማኔ ቴቄል ፋሬስ (Богатство Троица), [14/07/2024 4:51 ከሰዓት]
<th>Name</th>
                            <th>Reward</th>
                        </tr>
                    </thead>
                    <tbody>
                        {referrals.map((referral, index) => (
                            <tr key={index}>
                                <td>{referral.name}</td>
                                <td>{referral.reward}</td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
};

export default ReferralSystem;