const { ethers } = require("hardhat");

async function main() {
  const Pair = await ethers.getContractFactory("InterfinSwapPair");
  const pairInstance = await Pair.deploy();
  await pairInstance.waitForDeployment(); // For ethers v6

  console.log(`InterfinSwapPair deployed to: ${pairInstance.target}`);

  // OPTIONAL: Initialize the pair with your token addresses
  // const token0 = "0xYourToken0Address";
  // const token1 = "0xYourToken1Address";
  // const tx = await pairInstance.initialize(token0, token1);
  // await tx.wait();
  // console.log("InterfinSwapPair initialized with tokens!");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});