const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CasinoRoulette", function () {
  let owner, user;
  let contract;

  beforeEach(async () => {
    [owner, user] = await ethers.getSigners();
    const CasinoRoulette = await ethers.getContractFactory("CasinoRoulette");
    contract = await CasinoRoulette.deploy(
      "0x2Ca8E0C6409Dc076d0C4e5b0B2cC1A1f2c9C1Da3", // VRF Coordinator Goerli
      "0x79d3d8832d904592c0bf9818b62fdf8acb8fcf2a7a4ec01ee1ad5d67d2e576c8", // KeyHash
      0 // subscriptionId - replace later
    );
    await contract.deployed();
  });

  it("Should place a bet", async function () {
    const tx = await contract.connect(user).wager(0, 1, { value: ethers.utils.parseEther("0.1") });
    await tx.wait();
    const bet = await contract.bets(1);
    expect(bet.user).to.equal(user.address);
  });
});