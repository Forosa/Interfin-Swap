const { ethers } = require("hardhat");

async function main() {
  const feeToSetter = "0xDA9AA5f34098Ed386169809c43BAf8aC397573A1";
  const Factory = await ethers.getContractFactory("InterfinSwapFactory");
  const factoryInstance = await Factory.deploy(feeToSetter);
  await factoryInstance.waitForDeployment(); // For ethers v6

  console.log(`InterfinSwapFactory deployed to: ${factoryInstance.target}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});