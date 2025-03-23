import React, { useState } from 'react';
import { ethers } from 'ethers';
import AuthABI from '../Auth.json';
import './SignIn.css';

// Replace this with your deployed contract address
const authAddress = 'YOUR_CONTRACT_ADDRESS_HERE';

const SignIn = () => {
  const [account, setAccount] = useState<string | null>(null);
  const [formData, setFormData] = useState({
    signInEmail: '',
    signInUsername: ''
  });

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
  };

  const connectWallet = async () => {
    if (window.ethereum) {
      try {
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        setAccount(accounts[0]);
      } catch (error) {
        console.error('Error connecting to wallet:', error);
      }
    } else {
      alert('Please install MetaMask!');
    }
  };

  const signIn = async () => {
    if (!account) {
      alert('Please connect your wallet first');
      return;
    }

    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(authAddress, AuthABI.abi, signer);
      const { signInEmail, signInUsername } = formData;
      const tx = await contract.signIn(signInEmail, signInUsername);
      await tx.wait();
      alert('Sign-in successful');
    } catch (error) {
      console.error('Error signing in:', error);
      alert('Sign-in failed');
    }
  };

  return (
    <div className="signin-container">
      <button onClick={connectWallet}>Connect Wallet</button>
      {account && <div>Connected with account: {account}</div>}
      <h2>Sign In</h2>
      <input name="signInEmail" placeholder="Email" onChange={handleInputChange} />
      <input name="signInUsername" placeholder="Username" onChange={handleInputChange} />
      <button onClick={signIn}>Sign In</button>
    </div>
  );
};

export default SignIn;

