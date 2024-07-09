from mech_client.interact import interact, ConfirmationType

# Define the prompt for creating the NFT for Giften project
prompt_text = ("Create a celebratory and elegant digital artwork for an NFT that represents the 'Top Purchaser of the Year' at Giften. "
               "The image should symbolize loyalty, excellence, and customer satisfaction. Incorporate elements that reflect a rewarding experience, such as a digital trophy, purchase receipts, "
               "and elements of blockchain. The central motif should be a trophy or a medal with subtle hints of e-commerce and loyalty rewards aesthetics. The background should be sleek and modern "
               "with a touch of elegant technology themes, using a palette of gold, green, and white. Include inspirational elements like a rising graph or digital beams to signify customer satisfaction "
               "and growth. The style should be futuristic yet accessible, appealing to a professional audience.")

# Configuration for the interaction
agent_id = 2
tool_name = "stabilityai-stable-diffusion-v1-5"
chain_config = "celo"
private_key_path = "ethereum_private_key.txt"

# Perform the interaction to create the NFT
result = interact(
    prompt=prompt_text,
    agent_id=agent_id,
    tool=tool_name,
    chain_config=chain_config,
    confirmation_type=ConfirmationType.ON_CHAIN,
    private_key_path=private_key_path
)

# Print the result of the NFT creation
print(result)