import { ethers } from "hardhat";

async function main() {
  const latestBlock = await ethers.provider.getBlock("latest");
  console.log(latestBlock.number);
  const Staking = await ethers.getContractFactory("AFStaking");
  const staking = await Staking.deploy(
    "0x56B382090d916Eb6853550f4219eB9c53A346969",
    "0x1949880dD7C0E68a7AE2A51DE57445737bD217D5",
    1,
    latestBlock.number
  );

  await staking.deployed();

  console.log("Contract deployed to:", staking.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
