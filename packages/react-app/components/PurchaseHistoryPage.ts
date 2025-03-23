#### Purchase History Page (`PurchaseHistoryPage.tsx`)

```tsx
import React, { useEffect, useState } from 'react';
import { ethers } from 'ethers';
import MarketplaceABI from '../contracts/Marketplace.json';
import './PurchaseHistoryPage.css';

const marketplaceAddress = 'YOUR_MARKETPLACE_CONTRACT_ADDRESS';

const PurchaseHistoryPage: React.FC = () => {
    const [orders, setOrders] = useState<any[]>([]);

    useEffect(() => {
        const fetchOrders = async () => {
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner();
            const marketplace = new ethers.Contract(marketplaceAddress, MarketplaceABI.abi, signer);

            const userAddress = await signer.getAddress();
            const userOrders = await marketplace.getOrders(userAddress);
            setOrders(userOrders);
        };

        fetchOrders();
    }, []);

    return (
        <div className="purchase-history-container">
            <h2>Purchase History</h2>
            <div className="purchases-list">
                {orders.map((order, index) => (
                    <div key={index} className="purchase-card">
                        <p>Order ID: {order.orderId}</p>
                        <p>Item ID: {order.itemId}</p>
                        <p>Amount Paid: {ethers.utils.formatEther(order.amountPaid)} cUSD</p>
                        <p>Purchase Time: {new Date(order.purchaseTime * 1000).toLocaleString()}</p>
                    </div>
                ))}
            </div>
        </div>
    );
};

export default PurchaseHistoryPage;