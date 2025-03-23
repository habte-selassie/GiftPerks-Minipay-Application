import React from "react";
import { ethers } from "ethers";
import VipSubscription from "./artifacts/contracts/VipSubscription.sol/VipSubscription.json";

const VipSubscriptionPage = ({ contractAddress }) => {
    async function subscribe(level) {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        const contract = new ethers.Contract(contractAddress, VipSubscription.abi, signer);

        if (level === "Gold") {
            await contract.subscribeGold();
        } else if (level === "Platinum") {
            await contract.subscribePlatinum();
        }
        alert(`Successfully subscribed to ${level} level!`);
    }

    return (
        <div>
            <h2>VIP Subscription</h2>
            <div className="vip-cards">
                <div className="vip-card">
                    <h3>Gold</h3>
                    <p>Price: 20 cUSD</p>
                    <p>Benefits: 30% discount, 10 cUSD reward</p>
                    <button onClick={() => subscribe("Gold")}>Subscribe</button>
                </div>
                <div className="vip-card">
                    <h3>Platinum</h3>
                    <p>Price: 35 cUSD</p>
                    <p>Benefits: 50% discount, 20 cUSD reward</p>
                    <button onClick={() => subscribe("Platinum")}>Subscribe</button>
                </div>
            </div>
        </div>
    );
};

export default VipSubscriptionPage;
