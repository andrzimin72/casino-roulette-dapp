# 🎰 Casino Roulette dApp

A secure Ethereum-based roulette game using:
- Solidity
- Chainlink VRF
- React + Ethers.js frontend

## 🧰 Setup

1. Install dependencies:
bash
npm install

2. Create .env file from .env.example
PRIVATE_KEY=your_wallet_private_key
INFURA_API_KEY=your_infura_key

3. Deploy contract:
bash
npx hardhat run scripts/deploy.js --network goerli

4.Fund contract with LINK via Chainlink Faucet

5.Start frontend
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
