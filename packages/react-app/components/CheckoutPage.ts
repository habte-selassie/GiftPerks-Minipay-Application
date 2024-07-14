// #### Checkout Page (`CheckoutPage.tsx`)

import  { useState } from 'react';
import React from 'react';
import { ethers } from 'ethers';
import { useLocation, useNavigate } from 'react-router-dom';
import { useRouter } from 'next/navigation';
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
    //     <div className="checkout-container">
    //     <h2>Checkout</h2>
    //     <div className="item-details">
    //         <p>Description: {item.description}</p>
    //         <p>Price: {ethers.utils.formatEther(item.itemPrice)} cUSD</p>
    //     </div>
    //     <button onClick={handlePurchase} disabled={loading}>
    //         {loading ? 'Processing...' : 'Complete Purchase'}
    //     </button>
    //     {message && <p className="payment-success">{message}</p>}
    // </div>
    );
};

export default CheckoutPage;
// #### Checkout Component

// Create a `Checkout.tsx` component to handle the checkout process.

// ```tsx
// import React from "react";

// const Checkout = ({ item }) => {
//     return (
//         <div>
//             <h2>Checkout</h2>
//             <p>Item: {item.name}</p>
//             <p>Price: {item.price}</p>
//             <button onClick={item.buy}>Complete Purchase</button>
//         </div>
//     );
// };

// export default Checkout;