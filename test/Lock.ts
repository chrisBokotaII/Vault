import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre, { ethers } from "hardhat";

describe("Token", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployOneYearLockFixture() {
    const ONE_GWEI = 1_000_000_000;
    const Role = hre.ethers.encodeBytes32String("DEFAULT_ADMIN_ROLE");
    const lockedAmount = ONE_GWEI;

    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount, user1, user2] = await hre.ethers.getSigners();

    const Lock = await hre.ethers.getContractFactory("EMMA");
    const lock = await Lock.connect(owner).deploy();

    const Vault = await hre.ethers.getContractFactory("Vault");
    const vault = await Vault.deploy(lock.target);
    return { lock, owner, otherAccount, user1, user2, ONE_GWEI, vault, Role };
  }

  describe("Deployment", function () {
    it("should deploy the contract", async function () {
      const { lock, vault } = await loadFixture(deployOneYearLockFixture);
      expect(lock.target).to.be.properAddress;
      expect(vault.target).to.be.properAddress;
    });
    it("should set the right owner", async function () {
      const { lock, owner, otherAccount, Role, vault } = await loadFixture(
        deployOneYearLockFixture
      );
      expect(await lock.balanceOf(owner.address)).to.not.equal(0);
      await lock.connect(owner).pause();
      await lock.connect(owner).unpause();
      await lock.connect(owner).changeRole(vault.target);

      console.log(await lock.DEFAULT_ADMIN_ROLE(), owner.address);

      expect(await lock.hasRole(Role, vault.target)).to.equal(false);
    });
    it("should set the correct balances", async function () {
      const { lock, owner, ONE_GWEI } = await loadFixture(
        deployOneYearLockFixture
      );
      expect(await lock.balanceOf(owner.address)).to.not.equal(0);
    });
    it("should depose and mint token", async function () {
      const { lock, vault, owner, otherAccount, user1, user2 } =
        await loadFixture(deployOneYearLockFixture);
      await lock.connect(owner).changeRole(vault.target);
      expect(await lock.balanceOf(user1.address)).to.equal(0);
      console.log(
        `the rate is ${await vault.depotrate()} the withdraw rate ${await vault.withdrawRate()} the balance is ${await hre.ethers.provider.getBalance(
          user1.address
        )}`
      );

      await vault
        .connect(user1)
        .depositEther({ value: hre.ethers.parseEther("1") });

      expect(await lock.balanceOf(user1.address)).to.not.equal(0);
    });
    it("should withdraw some token", async function () {
      const { lock, vault, owner, otherAccount, user1, user2 } =
        await loadFixture(deployOneYearLockFixture);
      await lock.connect(owner).changeRole(vault.target);
      await vault
        .connect(user1)
        .depositEther({ value: hre.ethers.parseEther("10") });
      expect(await lock.balanceOf(user1.address)).to.not.equal(0);
      await vault.connect(user1).withdraw(10);
      console.log(await lock.balanceOf(user1.address));
      console.log(await hre.ethers.provider.getBalance(user1.address));
    });
  });
});
