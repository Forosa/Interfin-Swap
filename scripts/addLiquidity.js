const { ethers } = require("hardhat");

async function main() {
  // Replace these addresses with your deployed contract addresses!
  const routerAddress = "YOUR_ROUTER_ADDRESS_HERE";
  const IFNETAddress = "YOUR_IFNET_ADDRESS_HERE";
  const WBNBAddress = "YOUR_WBNB_ADDRESS_HERE";

  const [deployer] = await ethers.getSigners();
  const IFNET = await ethers.getContractAt("IERC20", IFNETAddress, deployer);
  const WBNB = await ethers.getContractAt("IERC20", WBNBAddress, deployer);
  const router = await ethers.getContractAt("InterfinSwapRouter02", routerAddress, deployer);

  // Set the amounts you want to add
  const amountIFNET = ethers.utils.parseUnits("100.0", 18); // Adjust decimals
  const amountWBNB = ethers.utils.parseUnits("1.0", 18);

  // Step 1: Approve the router to spend your tokens
  await IFNET.approve(routerAddress, amountIFNET);
  await WBNB.approve(routerAddress, amountWBNB);

  // Step 2: Add liquidity
  const deadline = Math.floor(Date.now() / 1000) + 60 * 20; // 20 minutes from now

  await router.addLiquidity(
    IFNETAddress,
    WBNBAddress,
    amountIFNET,
    amountWBNB,
    amountIFNET.mul(95).div(100), // 5% slippage
    amountWBNB.mul(95).div(100),
    deployer.address, // receive LP tokens
    deadline
  );

  console.log("Liquidity added!");
}

main().catch(console.error);