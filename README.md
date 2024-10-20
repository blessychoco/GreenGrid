# GreenGrid

GreenGrid is a decentralized renewable energy marketplace that enables individuals and communities to trade excess renewable energy using blockchain technology. This platform aims to incentivize clean energy adoption and improve energy distribution efficiency.

## Features

- Peer-to-peer energy trading
- Blockchain-based transactions for transparency and security
- Incentives for renewable energy production and consumption
- Real-time energy pricing based on supply and demand
- Whitelisting system for approved users
- Total energy traded tracking

## Smart Contract

The core functionality of GreenGrid is implemented in a Clarity smart contract. The contract allows users to:

- Buy energy credits
- Sell excess energy
- Check their energy credit balance
- View the current energy price

### Key Functions

- `buy-energy`: Purchase energy credits
- `sell-energy`: Sell excess energy credits
- `set-energy-price`: Admin function to update the energy price
- `add-to-whitelist`: Admin function to add users to the whitelist
- `remove-from-whitelist`: Admin function to remove users from the whitelist
- `get-energy-price`: View the current energy price
- `get-energy-balance`: Check a user's energy credit balance
- `check-whitelist`: Check if a user is whitelisted
- `get-total-energy-traded`: Get the total amount of energy traded on the platform

## Smart Contract Enhancements

The GreenGrid smart contract includes several improvements for robustness and security:

1. Whitelist system: Only approved users can participate in energy trading.
2. Input validation: Ensures that energy amounts are greater than zero.
3. Error handling: Specific error codes for different failure scenarios.
4. Total energy traded tracking: Keeps a record of the total energy exchanged on the platform.
5. Separate functions for adding and removing users from the whitelist.

## Getting Started

To interact with GreenGrid:

1. Set up a Stacks wallet
2. Connect to the Stacks network
3. Ensure you are added to the whitelist by the contract owner
4. Call the smart contract functions to buy or sell energy

## Contributing

We welcome contributions to improve GreenGrid. Please submit issues and pull requests on our GitHub repository.


## Author

Blessing Eze