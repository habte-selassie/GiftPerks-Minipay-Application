import {
    RainbowKitProvider,
    connectorsForWallets,
} from "@rainbow-me/rainbowkit";
import { injectedWallet } from "@rainbow-me/rainbowkit/wallets";
import "@rainbow-me/rainbowkit/styles.css";
import type { AppProps } from "next/app";
import { http, WagmiProvider, createConfig } from "wagmi";
import Layout from "../components/Layout";
import "../styles/globals.css";
import { celo, celoAlfajores } from "wagmi/chains";
import React, { useState } from 'react';
import { BrowserRouter as Router, Route, Link, Switch } from 'react-router-dom';
import SignUp from '../components/Auth/Signup';
import SignIn from '../components/Auth/Login';
import SignOutButton from '../components/Auth/Logout';
import './styles/App.css';


import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

const connectors = connectorsForWallets(
    [
        {
            groupName: "Recommended",
            wallets: [injectedWallet],
        },
    ],
    {
        appName: "Celo Composer",
        projectId: "044601f65212332475a09bc14ceb3c34",
    }
);

const config = createConfig({
    connectors,
    chains: [celo, celoAlfajores],
    transports: {
        [celo.id]: http(),
        [celoAlfajores.id]: http(),
    },
});

const queryClient = new QueryClient();


    const [account, setAccount] = useState<string | null>(null);
  
    const connectWallet = async () => {
      if (window.ethereum) {
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        setAccount(accounts[0]);
      }
    };

function App({ Component, pageProps }: AppProps) {
    return (
        <WagmiProvider config={config}>
            <QueryClientProvider client={queryClient}>
                <RainbowKitProvider>
                    <Layout>
                        <Component {...pageProps} />
                        <Router>
      <div className="app-container">
        <nav>
          <Link to="/signup">Sign Up</Link>
          <Link to="/signin">Sign In</Link>
          {account && <SignOutButton account={account} />}
        </nav>
        <button onClick={connectWallet}>Connect Wallet</button>
        <Switch>
          <Route path="/signup">
            <SignUp />
          </Route>
          <Route path="/signin">
            <SignIn />
          </Route>
        </Switch>
      </div>
    </Router>
                    </Layout>
                </RainbowKitProvider>
            </QueryClientProvider>
        </WagmiProvider>
    );
}








export default App;


```tsx
import React from 'react';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import MarketplacePage from './pages/MarketplacePage';
import ItemDetailsPage from './pages/ItemDetailsPage';
import CheckoutPage from './pages/CheckoutPage';
import PurchaseHistoryPage from './pages/PurchaseHistoryPage';

const App: React.FC = () => {
    return (
        <Router>
            <Routes>
                <Route path="/" element={<MarketplacePage />} />
                <Route path="/item/:id" element={<ItemDetailsPage />} />
                <Route path="/checkout" element={<CheckoutPage />} />
                <Route path="/purchases" element={<PurchaseHistoryPage />} />
            </Routes>
        </Router>
    );
};

export default App;
```


#### App.tsx

Update `App.tsx` to include routing for the new components.

```tsx
import React from "react";
import { BrowserRouter as Router, Route, Routes } from "react-router-dom";
import Marketplace from "./Marketplace";
import ItemDetails from "./ItemDetails";
import Checkout from "./Checkout";
import SellerForm from "./SellerForm";

const contractAddress = "YOUR_CONTRACT_ADDRESS";

const App = () => {
    return (
        <Router>
            <div>
                <Routes>
                    <Route path="/" element={<Marketplace contractAddress={contractAddress} />} />
                    <Route path="/item/:itemId" element={<ItemDetails contract

Address={contractAddress} />} />
                    <Route path="/checkout" element={<Checkout />} />
                    <Route path="/sell" element={<SellerForm contractAddress={contractAddress} />} />
                </Routes>
            </div>
        </Router>
    );
};

export default App;
```