import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
const {
  constants, // Common constants, like the zero address and largest integers
} = require("@openzeppelin/test-helpers");

describe("Airfoil Token", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshopt in every test.
  async function deployAirfoilToken() {
    const AirfoilToken = await ethers.getContractFactory("AirfoilToken");
    const airfoilToken = await AirfoilToken.deploy();

    return { airfoilToken };
  }

  const deployerAddress = "0x916081C20245D239125e3043A6BA519935610edF";
  const toAddress = "0x3dB716519Db5CfCaD3d591606e0E2c7D944668eE";

  describe("Deployment", function () {
    it("Should deploy contract successfully", async function () {
      const { airfoilToken } = await loadFixture(deployAirfoilToken);

      expect(await airfoilToken.balanceOf(deployerAddress)).to.equal(0);
    });
  });

  describe("Minting", function () {
    it("Should assign initial balance via minting", async function () {
      const { airfoilToken } = await loadFixture(deployAirfoilToken);

      await airfoilToken.mint(deployerAddress, 1000);

      expect(await airfoilToken.balanceOf(deployerAddress)).to.equal(1000);
    });

    it("Minting should emit transfer event", async function () {
      const { airfoilToken } = await loadFixture(deployAirfoilToken);

      await expect(airfoilToken.mint(deployerAddress, 1000))
        .to.emit(airfoilToken, "Transfer")
        .withArgs(constants.ZERO_ADDRESS, deployerAddress, 1000);
    });
  });

  describe("Transfer", function () {
    it("Should not be able to transfer amount more than balance", async function () {
      const { airfoilToken } = await loadFixture(deployAirfoilToken);

      await airfoilToken.mint(deployerAddress, 1000);

      await expect(airfoilToken.transfer(toAddress, 1007)).to.be.revertedWith(
        "ERC20: transfer amount exceeds balance"
      );
    });
  });
});
