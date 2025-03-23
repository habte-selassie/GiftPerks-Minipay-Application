import React from 'react';
import { ethers } from 'ethers';
import AuthABI from '../Auth.json';
import './SignOutButton.css';

// Replace this with your deployed contract address
const authAddress = 'YOUR_CONTRACT_ADDRESS_HERE';

const SignOutButton: React.FC<{ account: string | null }> = ({ account }) => {
  const signOut = async () => {
    if (!account) return;
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    const contract = new ethers.Contract(authAddress, AuthABI.abi, signer);
    const tx = await contract.signOut();
    await tx.wait();
  };

  return (
    <button className="signout-button" onClick={signOut}>Sign Out</button>
  );
};

export default SignOutButton;
