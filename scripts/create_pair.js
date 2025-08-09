const { ethers } = require("hardhat");

async function main() {
  // Replace with your actual router contract address
  const routerAddress = "YOUR_ROUTER_CONTRACT_ADDRESS";
  const WBNB = "0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c";
  const IFNET = "0x3fc84ecf9192bf6f2d12f204c50276af0984267d";
  const amountWBNB = ethers.parseUnits("0.01", 18); // Amount of WBNB to add
  const amountIFNET = ethers.parseUnits("100", 18); // Amount of IFNET to add

  const [deployer] = await ethers.getSigners();

  // Connect to token contracts (assuming standard ERC20 ABI)
  const ERC20_ABI = [
    "function approve(address spender, uint256 amount) external returns (bool)"
  ];
  const WBNBContract = new ethers.Contract(WBNB, ERC20_ABI, deployer);
  const IFNETContract = new ethers.Contract(IFNET, ERC20_ABI, deployer);

  // Approve router to spend your tokens
  console.log("Approving router for WBNB...");
  await (await WBNBContract.approve(routerAddress, amountWBNB)).wait();
  console.log("Approving router for IFNET...");
  await (await IFNETContract.approve(routerAddress, amountIFNET)).wait();

  // Connect to router contract (assuming UniswapV2Router02 ABI)
  const ROUTER_ABI = [
    "function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity)"
  ];
  const router = new ethers.Contract(routerAddress, ROUTER_ABI, deployer);

  // Add liquidity
  console.log("Adding liquidity...");
  const deadline = Math.floor(Date.now() / 1000) + 60 * 10; // 10 minutes from now
  const tx = await router.addLiquidity(
    WBNB,
    IFNET,
    amountWBNB,
    amountIFNET,
    0, // amountAMin
    0, // amountBMin
    deployer.address,
    deadline
  );
  const receipt = await tx.wait();

  console.log("Liquidity added! Transaction hash:", receipt.hash);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});