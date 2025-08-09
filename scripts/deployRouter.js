const { ethers } = require("hardhat");

async function main() {
  // Your provided Factory address
  const factoryAddress = "0xdD5ba68Fa492afBbF3F8847487E94dB8e1989506";
  // Official WBNB address for BNB Chain Mainnet
  const WBNBAddress = "0xBB4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";

  // Deploy the Router contract
  const Router = await ethers.getContractFactory("InterfinSwapRouter02");
  const router = await Router.deploy(factoryAddress, WBNBAddress);

  await router.deployed();

  console.log("Router deployed to address:", router.address);
}

main().catch(console.error);