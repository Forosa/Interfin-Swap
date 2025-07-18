const { ethers } = require("hardhat");

async function main() {
  const factoryAddress = "0xDA9AA5f34098Ed386169809c43BAf8aC397573A1";

  // Use correctly checksummed addresses
  const tokenA = "0x7ef95a0FeE0cEe6A8e0Fc2bA8dC9c6A0f9e6C5fF"; // USDT testnet
  const tokenB = "0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7"; // BUSD testnet

  const factory = await ethers.getContractAt("InterfinSwapFactory", factoryAddress);

  const tx = await factory.createPair(tokenA, tokenB);
  const receipt = await tx.wait();

  const event = receipt.events.find(e => e.event === "PairCreated");
  if (event) {
    console.log("New pair address:", event.args.pair);
  } else {
    console.log("PairCreated event not found. Check if the pair was created successfully.");
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});