const hre = require("hardhat");

async function main() {
  const network = hre.network.name;
  console.log(`Deploying to ${network} network...`);

  const vrfCoordinator = "0x2Ca8E0C6409Dc076d0C4e5b0B2cC1A1f2c9C1Da3"; // Goerli example
  const keyHash = "0x79d3d8832d904592c0bf9818b62fdf8acb8fcf2a7a4ec01ee1ad5d67d2e576c8";
  const subscriptionId = 0; // Replace with your Chainlink subscription ID

  const CasinoRoulette = await hre.ethers.getContractFactory("CasinoRoulette");
  const casinoRoulette = await CasinoRoulette.deploy(vrfCoordinator, keyHash, subscriptionId);

  await casinoRoulette.deployed();

  console.log("Contract deployed to:", casinoRoulette.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});