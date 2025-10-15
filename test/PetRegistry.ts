import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

describe("PetRegistry", function () {
  let petRegistry: any;
  let owner: any;
  let user1: any;
  let user2: any;

  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();
    petRegistry = await ethers.deployContract("PetRegistry");
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await petRegistry.owner()).to.equal(owner.address);
    });
  });

  describe("Pet Registration", function () {
    it("Should register a pet successfully", async function () {
      const petName = "Buddy";
      const petAge = 3;
      const isVaccinated = true;

      await petRegistry.connect(user1).registerPet(petName, petAge, isVaccinated);

      const [name, age, vaccinated] = await petRegistry.connect(user1).getPet();
      expect(name).to.equal(petName);
      expect(age).to.equal(petAge);
      expect(vaccinated).to.equal(isVaccinated);
      // Намеренная ошибка для тестирования workflow
      expect(age).to.equal(999);
    });

    it("Should not allow duplicate pet registration", async function () {
      await petRegistry.connect(user1).registerPet("Buddy", 3, true);
      
      await expect(
        petRegistry.connect(user1).registerPet("Max", 5, false)
      ).to.be.revertedWith("User already has a registered pet");
    });

    it("Should not allow empty pet name", async function () {
      await expect(
        petRegistry.connect(user1).registerPet("", 3, true)
      ).to.be.revertedWith("Pet name cannot be empty");
    });

    it("Should not allow pet age over 30", async function () {
      await expect(
        petRegistry.connect(user1).registerPet("Buddy", 31, true)
      ).to.be.revertedWith("Pet age cannot exceed 30 years");
    });
  });

  describe("Pet Information", function () {
    beforeEach(async function () {
      await petRegistry.connect(user1).registerPet("Buddy", 3, true);
    });

    it("Should return correct pet information", async function () {
      const [name, age, vaccinated] = await petRegistry.connect(user1).getPet();
      expect(name).to.equal("Buddy");
      expect(age).to.equal(3);
      expect(vaccinated).to.equal(true);
    });

    it("Should revert when getting pet info for unregistered user", async function () {
      await expect(
        petRegistry.connect(user2).getPet()
      ).to.be.revertedWith("User has no registered pet");
    });
  });

  describe("Vaccination Updates", function () {
    beforeEach(async function () {
      await petRegistry.connect(user1).registerPet("Buddy", 3, false);
    });

    it("Should update vaccination status", async function () {
      await petRegistry.connect(user1).updateVaccination(true);

      const [, , vaccinated] = await petRegistry.connect(user1).getPet();
      expect(vaccinated).to.equal(true);
    });

    it("Should revert when updating vaccination for unregistered user", async function () {
      await expect(
        petRegistry.connect(user2).updateVaccination(true)
      ).to.be.revertedWith("User has no registered pet");
    });
  });

  describe("Pet Deletion", function () {
    beforeEach(async function () {
      await petRegistry.connect(user1).registerPet("Buddy", 3, true);
    });

    it("Should allow owner to delete pet", async function () {
      await petRegistry.connect(owner).deletePet(user1.address);

      expect(await petRegistry.registered(user1.address)).to.equal(false);
    });

    it("Should not allow non-owner to delete pet", async function () {
      await expect(
        petRegistry.connect(user2).deletePet(user1.address)
      ).to.be.revertedWith("Only owner can call this function");
    });

    it("Should revert when deleting non-existent pet", async function () {
      await expect(
        petRegistry.connect(owner).deletePet(user2.address)
      ).to.be.revertedWith("User has no registered pet");
    });
  });

  describe("Multiple Users", function () {
    it("Should allow multiple users to register pets", async function () {
      await petRegistry.connect(user1).registerPet("Buddy", 3, true);
      await petRegistry.connect(user2).registerPet("Max", 5, false);

      const [name1] = await petRegistry.connect(user1).getPet();
      const [name2] = await petRegistry.connect(user2).getPet();

      expect(name1).to.equal("Buddy");
      expect(name2).to.equal("Max");
    });
  });
});
