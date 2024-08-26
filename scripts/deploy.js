const { ethers } = require("hardhat");

async function main() {
   // Get the contract factory
   const supplyChain = await ethers.getContractFactory("SupplyChain");

   console.log("Deploying SupplyChain contract...");

   // Deploy the contract
   const deployedSupplyChain = await supplyChain.deploy();

   // Wait for the deployment to be mined
   await deployedSupplyChain.deployed();

   // Output the contract address
   console.log("SupplyChain Contract deployed to:", deployedSupplyChain.address);
}

main().catch((error) => {
   console.error(error);
   process.exitCode = 1;
});
