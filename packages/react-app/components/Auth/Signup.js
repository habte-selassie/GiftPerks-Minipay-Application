import React, { useState } from 'react';
import { ethers } from 'ethers';
import AuthABI from '../Auth.json';
import './SignUp.css';

// Replace this with your deployed contract address
const authAddress = 'YOUR_CONTRACT_ADDRESS_HERE';

const SignUp = () => {
  const [account, setAccount] = useState<string | null>(null);
  const [formData, setFormData] = useState({
    name: '',
    username: '',
    email: '',
    age: ''
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

  const register = async () => {
    if (!account) {
      alert('Please connect your wallet first');
      return;
    }

    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(authAddress, AuthABI.abi, signer);
      const { name, username, email, age } = formData;
      const tx = await contract.register(name, username, email, parseInt(age));
      await tx.wait();
      alert('Registration successful');
    } catch (error) {
      console.error('Error registering user:', error);
      alert('Registration failed');
    }
  };

  return (
    <div className="form-container">
      <button onClick={connectWallet}>Connect Wallet</button>
      {account && <div>Connected with account: {account}</div>}
      <h2>Sign Up</h2>
      <input name="name" placeholder="Name" onChange={handleInputChange} />
      <input name="username" placeholder="Username" onChange={handleInputChange} />
      <input name="email" placeholder="Email" onChange={handleInputChange} />
      <input name="age" placeholder="Age" onChange={handleInputChange} />
      <button onClick={register}>Register</button>
    </div>
  );
};

export default SignUp;

