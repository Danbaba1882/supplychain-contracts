const { ethers, upgrades } = require("hardhat");

async function main() {
   const gas = await ethers.provider.getGasPrice()
   const chats = await ethers.getContractFactory("Chats");
   const operation = await ethers.getContractFactory("Operations");

   console.log("Deploying Operations contract...");
   const upgradeableOPs = await upgrades.upgradeProxy(operation.address, operation);
   await upgradeableOPs.deployed();
   console.log("Upgradeable upgradeableOPs Contract deployed to:", upgradeableOPs.address);

   console.log("Deploying CHATS contract...");
   const upgradeChats = await upgrades.upgradeProxy(chats.address, chats);
   await upgradeChats.deployed();
   console.log("Upgradeable CHATS Contract deployed to:", upgradeChats.address);
}

main().catch((error) => {
   console.error(error);
   process.exitCode = 1;
 });