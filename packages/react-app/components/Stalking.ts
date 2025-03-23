
import React, { useState, useEffect } from 'react';
import { useConnect, useAccount, useContract, useSigner } from 'wagmi';
import './App.css';

const StakingABI = [
  // Add the ABI of your staking contract here
];

const StakingAddress = "YOUR_CONTRACT_ADDRESS";
const APYPercentage = 10; // Example APY rate

function App() {
  const { connect, provider, connected } = useConnect();
  const account = useAccount();
  const signer = useSigner();
  const contract = useContract(StakingAddress, StakingABI);

  const [stakeAmount, setStakeAmount] = useState('');
  const [stakeBalance, setStakeBalance] = useState(0);
  const [rewards, setRewards] = useState(0);
  const [totalStaked, setTotalStaked] = useState(0);
  const [apyRate, setApyRate] = useState(APYPercentage);
  const [lockPeriod, setLockPeriod] = useState(7 * 24 * 60 * 60); // 7 days in seconds
  const [lockEndTime, setLockEndTime] = useState(null);

  useEffect(() => {
    if (contract && account) {
      updateBalances();
    }
  }, [contract, account]);

  const updateBalances = async () => {
    const balance = await contract.getStake(account);
    const reward = await contract.calculateRewards(account);
    const totalStaked = await contract.totalStaked();
    const userStake = await contract.stakes(account);

    setStakeBalance(balance);
    setRewards(reward);
    setTotalStaked(totalStaked);
    setLockEndTime(userStake.timestamp.toNumber() + lockPeriod);
  };

  const handleStake = async () => {
    if (!signer) {
      console.error("No signer found");
      return;
    }
    const tx = await contract.stake(stakeAmount, { signer });
    await tx.wait();
    setStakeAmount('');
    updateBalances();
  };

  const handleUnstake = async () => {
    if (!signer) {
      console.error("No signer found");
      return;
    }
    const tx = await contract.withdrawStake({ signer });
    await tx.wait();
    updateBalances();
  };

  const handleClaimRewards = async () => {
    if (!signer) {
      console.error("No signer found");
      return;
    }
    const tx = await contract.claimRewards({ signer });
    await tx.wait();
    updateBalances();
  };

  const formatTime = (seconds) => {
    const d = Math.floor(seconds / (3600 * 24));
    const h = Math.floor((seconds % (3600 * 24)) / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    const s = Math.floor(seconds % 60);
    return `${d}d ${h}h ${m}m ${s}s`;
  };

  const timeLeft = lockEndTime ? lockEndTime - Math.floor(Date.now() / 1000) : 0;

  return (
    <div className="App">
      <header className="App-header">
        <h1>Staking DApp</h1>
        {!connected ? (
          <button onClick={() => connect()}>Connect Wallet</button>
        ) : (
          <div className="staking-container">
            <div className="balance">
              <p>Staked Balance: {stakeBalance} Tokens</p>
              <p>Rewards: {rewards} Tokens</p>
            </div>
            <div className="stake">
              <input
                type="number"
                value={stakeAmount}
                onChange={(e) => setStakeAmount(e.target.value)}
                placeholder="Stake Amount"
              />
              <button onClick={handleStake}>Stake</button>
            </div>
            <div className="unstake">
              <button onClick={handleUnstake} disabled={timeLeft > 0}>Unstake</button>
            </div>
            <button onClick={handleClaimRewards}>Claim Rewards</button>
            <div className="info-cards">
              <div className="card">
                <h3>Total Value Locked</h3>
                <p>{totalStaked} Tokens</p>
              </div>
              <div className="card">
                <h3>APY Rate</h3>
                <p>{apyRate}%</p>
              </div>
              <div className="card">
                <h3>Lock Period</h3>
                <p>{formatTime(timeLeft)}</p>
              </div>
            </div>
          </div>
        )}
      </header>
    </div>
  );
}

export default App;

// ### Updated React Component with Wagmi

// First, install Wagmi and other necessary packages:
// ```bash
// npm install wagmi ethers@^5.0.0 @wagmi/core
// ```

// Here's the updated React component using Wagmi:

// // ```jsx
// import React, { useEffect, useState } from 'react';
// import { ethers } from 'ethers';
// import { useAccount, useConnect, useContract, useProvider, useSigner } from 'wagmi';
// import { InjectedConnector } from 'wagmi/connectors/injected';
// import './App.css';

// const stakingABI = [
//   // Add the ABI of your staking contract here
// ];

// const stakingAddress = "YOUR_CONTRACT_ADDRESS";

// function App() {
//   const { connect } = useConnect({
//     connector: new InjectedConnector(),
//   });
//   const { address, isConnected } = useAccount();
//   const provider = useProvider();
//   const { data: signer } = useSigner();
//   const contract = useContract({
//     address: stakingAddress,
//     abi: stakingABI,
//     signerOrProvider: signer || provider,
//   });

//   const [stakeAmount, setStakeAmount] = useState('');
//   const [rewards, setRewards] = useState(0);
//   const [stakeBalance, setStakeBalance] = useState(0);
//   const [totalStaked, setTotalStaked] = useState(0);
//   const [apyRate, setApyRate] = useState(20); // Example APY rate
//   const [lockPeriod, setLockPeriod] = useState(7 * 24 * 60 * 60); // 7 days in seconds
//   const [lockEndTime, setLockEndTime] = useState(null);

//   useEffect(() => {
//     if (isConnected) {
//       updateBalances();
//     }
//   }, [isConnected, address]);

//   const updateBalances = async () => {
//     const balance = await contract.getStake(address);
//     const reward = await contract.calculateRewards(address);
//     const totalStaked = await contract.totalStaked();
//     const userStake = await contract.stakes(address);

//     setStakeBalance(ethers.utils.formatEther(balance));
//     setRewards(ethers.utils.formatEther(reward));
//     setTotalStaked(ethers.utils.formatEther(totalStaked));
//     setLockEndTime(userStake.timestamp.toNumber() + lockPeriod);
//   };

//   const handleStake = async () => {
//     if (!isConnected) {
//       connect();
//       return;
//     }
//     const tx = await contract.stake(ethers.utils.parseEther(stakeAmount));
//     await tx.wait();
//     updateBalances();
//     setStakeAmount('');
//   };

//   const handleUnstake = async () => {
//     if (!isConnected) {
//       connect();
//       return;
//     }
//     const tx = await contract.withdrawStake();
//     await tx.wait();
//     updateBalances();
//   };

//   const handleClaimRewards = async () => {
//     if (!isConnected) {
//       connect();
//       return;
//     }
//     const tx = await contract.claimRewards();
//     await tx.wait();
//     updateBalances();
//   };

//   const formatTime = (seconds) => {
//     const d = Math.floor(seconds / (3600 * 24));
//     const h = Math.floor((seconds % (3600 * 24)) / 3600);
//     const m = Math.floor((seconds % 3600) / 60);
//     const s = Math.floor(seconds % 60);
//     return `${d}d ${h}h ${m}m ${s}s`;
//   };

//   const timeLeft = lockEndTime ? lockEndTime - Math.floor(Date.now() / 1000) : 0;

//   return (
//     <div className="App">
//       <header className="App-header">
//         <h1>Staking DApp</h1>
//         <button onClick={connect}>
//           {isConnected ? `Connected: ${address.substring(0, 6)}...${address.substring(address.length - 4)}` : 'Connect Wallet'}
//         </button>
//         {isConnected && (
//           <div className="staking-container">
//             <div className="balance">
//               <p>Staked Balance: {stakeBalance} Tokens</p>
//               <p>Rewards: {rewards} Tokens</p>
//             </div>
//             <div className="stake">
//               <input
//                 type="number"
//                 value={stakeAmount}
//                 onChange={(e) => setStakeAmount(e.target.value)}
//                 placeholder="Stake Amount"
//               />
//               <button onClick={handleStake}>Stake</button>
//             </div>
//             <div className="unstake">
//               <button onClick={handleUnstake} disabled={timeLeft > 0}>Unstake</button>
//             </div>
//             <button onClick={handleClaimRewards}>Claim Rewards</button>
//             <div className="info-cards">
//               <div className="card">
//                 <h3>Total Value Locked</h3>
//                 <p>{totalStaked} Tokens</p>
//               </div>
//               <div className="card">
//                 <h3>APY Rate</h3>
//                 <p>{apyRate}%</p>
//               </div>
//               <div className="card">
//                 <h3>Lock Period</h3>
//                 <p>{formatTime(timeLeft)}</p>
//               </div>
//             </div>
//           </div>
//         )}
//       </header>
//     </div>
//   );
// }

// export default App;


// ### Explanation:

// 1. **Smart Contract**: The smart contract handles staking, unstaking, and claiming rewards. It ensures users can only stake, unstake, and claim once per week. It also calculates rewards based on the APY percentage and transfers them to the user.

// 2. **React Component**: The React component interacts with the smart contract using Wagmi. When the user clicks the `Stake`, `Unstake`, or `Claim Rewards` button, it connects the wallet if not already connected, and then performs the respective action. The UI updates dynamically by fetching the current staking balance, rewards, total staked amount, and lock end time from the smart contract.

// 3. **Real-Time

//  Updates**: The `useEffect` hook ensures that the balances are updated whenever the user connects their wallet or performs an action.

// 4. **Time Formatting**: The `formatTime` function converts seconds into a more readable format (days, hours, minutes, and seconds).

// 5. **Wagmi**: Wagmi is used to handle wallet connection and contract interactions more seamlessly compared to Ethers.js.

// This implementation ensures that the staking application works as specified, with a once-a-week staking, claiming, and unstaking period, reward calculation based on APY, and limited reward distribution to 10% of users per week.