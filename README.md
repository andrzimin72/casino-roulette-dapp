# Casino Roulette dApp

The provided Solidity contract CasinoRoulette implements a basic roulette betting system on the Ethereum blockchain. Below is an explanation of its functionality, potential issues, and suggestions for improvement.

Contract Overview
This contract allows users to place bets (ether) on either:

The color of the pocket where the ball lands (red or black);

A specific number from 0 to 36 or 00 (represented as -1);

After placing a bet using wager, the user must later call spin to resolve the bet using a pseudo-random number generator based on blockhashes.

A secure Ethereum-based roulette game using:
- Solidity
- Chainlink VRF
- React + Ethers.js frontend

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
