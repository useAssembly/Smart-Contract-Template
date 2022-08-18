import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
const {
  constants, // Common constants, like the zero address and largest integers
} = require("@openzeppelin/test-helpers");

describe("Staking", function () {
  let nftCollectionAddress;
  let rewardTokenAddress;
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshopt in every test.
  async function deployAFStaking() {
    const AirfoilToken = await ethers.getContractFactory("AirfoilToken");
    const airfoilToken = await AirfoilToken.deploy();
    await airfoilToken.deployed();
    rewardTokenAddress = airfoilToken.address;

    const NftContract = await ethers.getContractFactory("MudCats");
    const nftContract = await NftContract.deploy();
    await nftContract.deployed();
    nftCollectionAddress = nftContract.address;

    const AFStaking = await ethers.getContractFactory("AFStaking");
    const latestBlock = await ethers.provider.getBlock("latest");
    const afStaking = await AFStaking.deploy(
      nftCollectionAddress,
      rewardTokenAddress,
      1,
      latestBlock.number
    );

    return { afStaking, nftContract, airfoilToken };
  }

  describe("Deployment", function () {
    it("Should deploy contract successfully", async function () {
      const { afStaking } = await loadFixture(deployAFStaking);

      expect(await afStaking.rewardPerBlock()).to.equal(1);
    });
  });

  describe("Staking", function () {
    it("Should stake nft token successfully", async function () {
      const { afStaking, nftContract } = await loadFixture(deployAFStaking);
      const [owner] = await ethers.getSigners();

      await nftContract.flipSale();
      await nftContract.mint(1);
      expect(await nftContract.balanceOf(owner.address)).to.equal(1);
    });
  });
});
