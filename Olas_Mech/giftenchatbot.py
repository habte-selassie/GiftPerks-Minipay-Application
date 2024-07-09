from mech_client.interact import interact, ConfirmationType
from dotenv import load_dotenv
import os

load_dotenv()  # Load the env variables from the .env file

# Define a function to get prompts for different use cases
def get_prompt(prompt_text, agent_id=2, tool_name="openai-gpt-3.5-turbo", chain_config="celo", private_key_path="ethereum_private_key.txt"):
    result = interact(
        prompt=prompt_text,
        agent_id=agent_id,
        tool=tool_name,
        chain_config=chain_config,
        confirmation_type=ConfirmationType.ON_CHAIN,
        private_key_path=private_key_path
    )
    return result

# Define use case scenarios and corresponding prompts
use_cases = {
    "reward_repeat_customers": "A customer makes a purchase at a small business. After their second purchase, they receive a blockchain-backed gift card as a reward for their loyalty.",
    "reward_referrals": "A customer refers a friend to the business. When the referred friend makes their first purchase, the referring customer receives a blockchain-backed gift card.",
    "birthday_rewards": "Customers receive special rewards on their birthdays, encouraging them to visit and make purchases during their birthday month.",
    "seasonal_promotions": "The business runs seasonal promotions (e.g., holiday sales). Customers who participate receive blockchain-backed gift cards or discounts.",
    "community_engagement_rewards": "Customers earn rewards for participating in local events or supporting community initiatives sponsored by the business.",
    "feedback_reviews_rewards": "Customers receive rewards, such as blockchain-backed gift cards, for leaving feedback or reviews about their experiences with the business.",
    "social_media_engagement_rewards": "Customers earn rewards for engaging with the business on social media platforms, such as sharing posts or tagging friends.",
    "vip_membership_rewards": "The business offers exclusive rewards and benefits to VIP or premium members who achieve certain spending or loyalty milestones.",
    "charity_rewards": "Customers earn rewards by supporting charitable causes or purchasing specific products that contribute to charity.",
    "gamification_challenges": "The business gamifies the customer experience with challenges or missions, rewarding customers with blockchain-backed gift cards for completing tasks.",
    "preorder_rewards": "Customers receive rewards for pre-ordering products or participating in exclusive product launch events hosted by the business.",
    "personalized_offers": "Customers receive personalized offers and product recommendations based on their purchase history and preferences.",
    "mobile_wallet_integration": "Customers store and manage blockchain-backed gift cards and loyalty rewards conveniently in their mobile wallets for seamless redemption.",
    "subscription_rewards_program": "Customers subscribe to a rewards program that offers ongoing benefits such as blockchain-backed gift cards or exclusive discounts."
}

# Function to handle the prompts for each use case
def handle_use_case(use_case):
    if use_case in use_cases:
        prompt_text = use_cases[use_case]
        result = get_prompt(prompt_text)
        print(f"Result for {use_case}: {result}")
    else:
        print(f"Use case {use_case} not found.")

# Example usage for the 'reward_repeat_customers' use case
handle_use_case("reward_repeat_customers")