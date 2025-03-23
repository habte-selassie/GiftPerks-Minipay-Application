
#### Item Details Page (`ItemDetailsPage.tsx`)

```tsx
import React from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import './ItemDetailsPage.css';

const ItemDetailsPage: React.FC = () => {
    const location = useLocation();
    const navigate = useNavigate();
    const { item } = location.state;

    const proceedToCheckout = () => {
        navigate('/checkout', { state: { item } });
    };

    return (
        <div className="item-details-container">
            <h2>{item.description}</h2>
            <p>Price: {item.itemPrice} cUSD</p>
            {item.is

Sold ? (
                <p className="sold-text">This item is sold</p>
            ) : (
                <button onClick={proceedToCheckout}>Buy Now</button>
            )}
        </div>
    );
};

export default ItemDetailsPage;

```

#### ItemDetails Component

Create an `ItemDetails.tsx` component to show item details and handle purchase.

```tsx
import React, { useEffect, useState } from "react";
import { ethers } from "ethers";
import { useParams } from "react-router-dom";
import GiftenMarketPlace from "./artifacts/contracts/GiftenMarketPlace.sol/GiftenMarketPlace.json";

const ItemDetails = ({ contractAddress }) => {
    const { itemId } = useParams();
    const [item, setItem] = useState(null);

    useEffect(() => {
        loadItem();
    }, []);

    async function loadItem() {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const contract = new ethers.Contract(contractAddress, GiftenMarketPlace.abi, provider);
        const item = await contract.getItem(itemId);
        setItem(item);
    }

    async function buyItem() {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        const contract = new ethers.Contract(contractAddress, GiftenMarketPlace.abi, signer);
        await contract.buyItem(itemId);
        alert("Purchase successful!");
        window.location.href = "/purchases";
    }

    if (!item) return <div>Loading...</div>;

    return (
        <div>
            <h2>{item.name}</h2>
            <p>{item.description}</p>
            <p>Price: {ethers.utils.formatEther(item.itemPrice)} cUSD</p>
            <button onClick={buyItem}>Buy</button>
        </div>
    );
};

export default ItemDetails;