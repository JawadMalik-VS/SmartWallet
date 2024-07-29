const hre = require("hardhat");

async function main() {
  const SmartWallet = await hre.ethers.getContractFactory("SmartWallet");
  const smartWallet = await SmartWallet.deploy();
  await smartWallet.getDeployedCode();
  let getAddress = await smartWallet.getAddress();
  console.log("Contract deployed to:", getAddress);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

//deployed address : 0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9
