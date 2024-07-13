### Frontend

I'll provide the corresponding React frontend code to match the features in the updated smart contract.

#### Marketplace Page (`MarketplacePage.tsx`)

```tsx
import React, { useEffect, useState } from 'react';
import { ethers } from 'ethers';
import MarketplaceABI from '../contracts/Marketplace.json';
import './MarketplacePage.css';
import { useNavigate } from 'react-router-dom';

const marketplaceAddress = 'YOUR_MARKETPLACE_CONTRACT_ADDRESS';

const MarketplacePage: React.FC = () => {
    const [marketplaceContract, setMarketplaceContract] = useState<any>();
    const [items, setItems] = useState<any[]>([]);
    const navigate = useNavigate();

    useEffect(() => {
        const init = async () => {
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner();
            const marketplace = new ethers.Contract(marketplaceAddress, MarketplaceABI.abi, signer);
            setMarketplaceContract(marketplace);

            const itemCount = await marketplace.itemIndex();
            const itemsData = await Promise.all(
                Array.from({ length: itemCount.toNumber() }, (_, index) => marketplace.giftItems(index))
            );
            setItems(itemsData);
        };
        init();
    }, []);

    const viewItemDetails = (item: any) => {
        navigate(`/item/${item.itemId}`, { state: { item } });
    };

    return (
        <div className="marketplace-container">
            <h2>Marketplace</h2>
            <div className="items-list">
                {items.map((item) => (
                    <div key={item.itemId} className="item-card" onClick={() => viewItemDetails(item)}>
                        <h3>{item.description}</h3>
                        <p>Price: {ethers.utils.formatEther(item.itemPrice)} cUSD</p>
                        {item.isSold ? <p className="sold-text">Sold</p> : <button>Buy Now</button>}
                    </div>
                ))}
            </div>
        </div>
    );
};

export default MarketplacePage;
### React Front-End

We need to create UI components for the marketplace, item details, checkout, and seller form with CRUD operations.

#### Dependencies

Ensure you have the following dependencies installed in your React project:

```sh
npm install @openzeppelin/contracts ethers web3modal
```

#### Marketplace Component

Create a `Marketplace.tsx` component to display items.

```tsx
import React, { useEffect, useState } from "react";
import { ethers } from "ethers";
import GiftenMarketPlace from "./artifacts/contracts/GiftenMarketPlace.sol/GiftenMarketPlace.json";

const Marketplace = ({ contractAddress }) => {
    const [items, setItems] = useState([]);

    useEffect(() => {
        loadItems();
    }, []);

    async function loadItems() {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const contract = new ethers.Contract(contractAddress, GiftenMarketPlace.abi, provider);
        const items = await contract.getAllItems();
        setItems(items);
    }

    return (
        <div>
            <h2>Marketplace</h2>
            {items.map((item, index) => (
                <div key={index} className="item-card">
                    <h3>{item.name}</h3>
                    <p>{item.description}</p>
                    <p>Price: {ethers.utils.formatEther(item.itemPrice)} cUSD</p>
                    <button onClick={() => window.location.href = `/item/${item.itemId}`}>View Details</button>
                </div>
            ))}
        </div>
    );
};

export default Marketplace;