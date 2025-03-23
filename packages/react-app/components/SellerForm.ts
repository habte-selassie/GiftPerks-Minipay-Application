
#### Seller Form Component

Create a `SellerForm.tsx` component for sellers to create and manage items.

```tsx
import React, { useState } from "react";
import { ethers } from "ethers";
import GiftenMarketPlace from "./artifacts/contracts/GiftenMarketPlace.sol/GiftenMarketPlace.json";

const SellerForm = ({ contractAddress }) => {
    const [name, setName] = useState("");
    const [price, setPrice] = useState("");
    const [description, setDescription] = useState("");

    async function handleSubmit(event) {
        event.preventDefault();
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        const contract = new ethers.Contract(contractAddress, GiftenMarketPlace.abi, signer);

        const itemPrice = ethers.utils.parseUnits(price, "ether");
        await contract.createItem(name, itemPrice, description);
        alert("Item created!");
        setName("");
        setPrice("");
        setDescription("");
    }

    return (
        <form onSubmit={handleSubmit}>
            <h2>Create Item</h2>
            <input
                type="text"
                placeholder="Name"
                value={name}
                onChange={(e) => setName(e.target.value)}
            />
            <input
                type="text"
                placeholder="Price"
                value={price}
                onChange={(e) => setPrice(e.target.value)}
            />
            <textarea
                placeholder="Description"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
            ></textarea>
            <button type="submit">Create</button>
        </form>
    );
};

export default SellerForm;