
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