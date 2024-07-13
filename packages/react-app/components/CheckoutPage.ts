#### Checkout Page (`CheckoutPage.tsx`)

```tsx
import React, { useState } from 'react';
import { ethers } from 'ethers';
import { useLocation, useNavigate } from 'react-router-dom';
import MarketplaceABI from '../contracts/Marketplace.json';
import './CheckoutPage.css';

const marketplaceAddress = 'YOUR_MARKETPLACE_CONTRACT_ADDRESS';

const CheckoutPage: React.FC = () => {
    const location = useLocation();
    const navigate = useNavigate();
    const { item } = location.state;
    const [loading, setLoading] = useState(false);
    const [message, setMessage] = useState('');

    const handlePurchase = async () => {
        setLoading(true);
        try {
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner();
            const marketplace = new ethers.Contract(marketplaceAddress, MarketplaceABI.abi, signer);

            const transaction = await marketplace.buyItem(item.itemId, 0);
            await transaction.wait();

            setMessage('Purchase successful!');
            setTimeout(() => {
                navigate('/');
            }, 3000);
        } catch (error) {
            console.error(error);
            setMessage('Purchase failed. Please try again.');
        }
        setLoading(false);
    };

    return (
        <div className="checkout-container">
            <h2>Checkout</h2>
            <div className="item-details">
                <p>Description: {item.description}</p>
                <p>Price: {ethers.utils.formatEther(item.itemPrice)} cUSD</p>
            </div>
            <button onClick={handlePurchase} disabled={loading}>
                {loading ? 'Processing...' : 'Complete Purchase'}
            </button>
            {message && <p className="payment-success">{message}</p>}
        </div>
    );
};

export default CheckoutPage;