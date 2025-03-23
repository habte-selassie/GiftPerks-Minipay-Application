// export default MarketplacePage;
// ### React Front-End

// We need to create UI components for the marketplace, item details, checkout, and seller form with CRUD operations.

// #### Dependencies

// Ensure you have the following dependencies installed in your React project:

// ```sh
//npm install @openzeppelin/contracts ethers web3modal
import React, { useEffect, useState } from 'react';
import { ethers } from 'ethers';
import { useNavigate } from 'react-router-dom';
import MarketplaceABI from '../contracts/Marketplace.json';
import VipSubscriptionABI from '../contracts/VipSubscription.json';
import './MarketplacePage.css';

const marketplaceAddress = 'YOUR_MARKETPLACE_CONTRACT_ADDRESS';
const vipAddress = 'YOUR_VIP_CONTRACT_ADDRESS';

const MarketplacePage: React.FC = () => {
    const [items, setItems] = useState<any[]>([]);
    const [marketplaceContract, setMarketplaceContract] = useState<any>();
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

            // Fetch VIP discounts
            const vipContract = new ethers.Contract(vipAddress, VipSubscriptionABI.abi, signer);
            const discountedItems = await Promise.all(
                itemsData.map(async (item) => {
                    const discount = await vipContract.getDiscount(item.seller);
                    item.discountedPrice = item.itemPrice * (100 - discount) / 100;
                    return item;
                })
            );

            setItems(discountedItems);
        };
        init();
    }, []);

    const viewItemDetails = (item: any) => {
        navigate(`/item/${item.itemId}`, { state: { item } });
    };

    const buyItem = async (itemId: number, price: number) => {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        const marketplace = new ethers.Contract(marketplaceAddress, MarketplaceABI.abi, signer);
        await marketplace.buyItem(itemId, { value: ethers.utils.parseUnits(price.toString(), "ether") });
        alert("Purchase successful!");
        // Reload items after purchase
        loadItems();
    };

    async function loadItems() {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const marketplaceContract = new ethers.Contract(marketplaceAddress, MarketplaceABI.abi, provider);
        const vipContract = new ethers.Contract(vipAddress, VipSubscriptionABI.abi, provider);
        const items = await marketplaceContract.getAllItems();
        const discountedItems = await Promise.all(items.map(async (item) => {
            const discount = await vipContract.getDiscount(item.seller);
            item.discountedPrice = item.itemPrice * (100 - discount) / 100;
            return item;
        }));
        setItems(discountedItems);
    }

    return (
        // <div className="marketplace-container">
        //     <h2>Marketplace</h2>
        //     <div className="items-list">
        //         {items.map((item) => (
        //             <div key={item.itemId} className="item-card" onClick={() => viewItemDetails(item)}>
        //                 <h3>{item.description}</h3>
        //                 <p>Price: {ethers.utils.formatUnits(item.discountedPrice.toString(), "ether")} cUSD</p>
        //                 {item.isSold ? <p className="sold-text">Sold</p> : <button onClick={() => buyItem(item.itemId, item.discountedPrice)}>Buy Now</button>}
        //             </div>
        //         ))}
        //     </div>
        // </div>
    );
};

export default MarketplacePage;
