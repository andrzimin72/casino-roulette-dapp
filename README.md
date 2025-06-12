# Casino Roulette dApp

This is provided Solidity contract CasinoRoulette implements a basic roulette betting system on the Ethereum blockchain. Below is an explanation of its functionality, potential issues, and suggestions for improvement.

Contract Overview
This contract allows users to place bets (ether) on either. The color of the pocket where the ball lands (red or black).A specific number from 0 to 36 or 00 (represented as -1). After placing a bet using wager, the user must later call spin to resolve the bet using a pseudo-random number generator based on blockhashes.

A secure Ethereum-based roulette game using: Solidity, Chainlink VRF, React + Ethers.js frontend.

Enums and Structs: BetType defines the type of bet. Bet stores all details about a placed bet.

Constants and Storage: There are 38 pockets in American roulette: 0, 00 (-1), and 1–36. Colors are mapped via a storage mapping instead of a constant due to Solidity limitations at the time.

Events: Used to notify off-chain applications when a bet is placed or resolved.

Functions:
Constructor. Sets up color mappings for red numbers. Black is assumed to be default (0).

Place Bet. Accepts ether for a bet. Validates the input based on the bet type.

Resolve Bet. Uses blockhash(bet.block) to generate pseudo-randomness. Pays out if the bet wins. Deletes the bet after resolution.

Helper Functions. Allows depositing funds into the contract. Allows the owner to destroy the contract and reclaim funds.

Security and Design Issues:
1. Randomness Vulnerability
This uses blockhash of a future block (bet.block) to generate randomness. However, miners can manipulate the outcome by choosing not to publish certain blocks.
Not secure for high-stakes gambling.
Fix : Use a trusted randomness source like Chainlink VRF or commit-reveal schemes.
2. Reentrancy Risk solidity
Using transfer() is safe since it forwards only 2300 gas, but better practice is to use checks-effects-interactions pattern.
Fix : Consider using OpenZeppelin’s Address.sendValue() with proper reentrancy guards if more complex logic is added.
3. No House Edge
Players who win get full payout: 2x for colors, 35x for numbers.
Real casinos take a cut (house edge).
Fix : Add a house edge, e.g., reduce payouts slightly.
4. Unbounded Mapping
bets is a mapping that keeps growing unless deleted.
Each bet stored forever unless spin is called.
Fix : Enforce a timeout mechanism or incentivize users to resolve bets.
5. No Withdraw Function
Users can't withdraw their winnings if something goes wrong.
Fix : Add a function for users to claim their winnings if the game fails to execute properly.
6. No Gas Limit Handling
If many bets are unresolved, resolving them may exceed gas limits.
Fix : Encourage off-chain resolution or batch processing.

The CasinoRoulette contract is a good educational example of how to build simple decentralized gambling games on Ethereum. 

## Setup

1. Install dependencies:
bash
npm install

2. Create .env file from .env.example
PRIVATE_KEY=your_wallet_private_key
INFURA_API_KEY=your_infura_key

3. Deploy contract:
bash
npx hardhat run scripts/deploy.js --network goerli

4. Fund contract with LINK via Chainlink Faucet

5. Start frontend
bash
cd frontend
npm install
npm start

Contract ABI
After deploying, save the ABI from:
artifacts/contracts/CasinoRoulette.sol/CasinoRoulette.json
into:
frontend/src/contract/CasinoRouletteABI.json
Also update:
frontend/src/contract/addresses.js
with your deployed contract address.
