// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { Test } from "forge-std/Test.sol";
import { PetRegistry } from "./PetRegistry.sol";

contract PetRegistryTest is Test {
    PetRegistry public petRegistry;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        petRegistry = new PetRegistry();
    }

    function testOwnerIsSet() public view {
        assertEq(petRegistry.owner(), owner);
    }

    function testRegisterPet() public {
        string memory petName = "Buddy";
        uint256 petAge = 3;
        bool isVaccinated = true;

        vm.prank(user1);
        petRegistry.registerPet(petName, petAge, isVaccinated);

        vm.prank(user1);
        (string memory name, uint256 age, bool vaccinated) = petRegistry.getPet();
        
        assertEq(name, petName);
        assertEq(age, petAge);
        assertEq(vaccinated, isVaccinated);
        assertTrue(petRegistry.registered(user1));
    }


    function testCannotRegisterDuplicatePet() public {
        vm.prank(user1);
        petRegistry.registerPet("Buddy", 3, true);

        vm.prank(user1);
        vm.expectRevert("User already has a registered pet");
        petRegistry.registerPet("Max", 5, false);
    }

    function testCannotRegisterEmptyName() public {
        vm.prank(user1);
        vm.expectRevert("Pet name cannot be empty");
        petRegistry.registerPet("", 3, true);
    }

    function testCannotRegisterAgeOver30() public {
        vm.prank(user1);
        vm.expectRevert("Pet age cannot exceed 30 years");
        petRegistry.registerPet("Buddy", 31, true);
    }

    function testGetPetForUnregisteredUser() public {
        vm.prank(user2);
        vm.expectRevert("User has no registered pet");
        petRegistry.getPet();
    }

    function testUpdateVaccination() public {
        vm.prank(user1);
        petRegistry.registerPet("Buddy", 3, false);

        vm.prank(user1);
        petRegistry.updateVaccination(true);

        vm.prank(user1);
        (, , bool vaccinated) = petRegistry.getPet();
        assertTrue(vaccinated);
    }

    function testUpdateVaccinationForUnregisteredUser() public {
        vm.prank(user2);
        vm.expectRevert("User has no registered pet");
        petRegistry.updateVaccination(true);
    }

    function testDeletePet() public {
        vm.prank(user1);
        petRegistry.registerPet("Buddy", 3, true);

        petRegistry.deletePet(user1);
        assertFalse(petRegistry.registered(user1));
    }

    function testDeletePetOnlyOwner() public {
        vm.prank(user1);
        petRegistry.registerPet("Buddy", 3, true);

        vm.prank(user2);
        vm.expectRevert("Only owner can call this function");
        petRegistry.deletePet(user1);
    }

    function testDeleteNonExistentPet() public {
        vm.expectRevert("User has no registered pet");
        petRegistry.deletePet(user2);
    }

    function testMultipleUsersCanRegisterPets() public {
        vm.prank(user1);
        petRegistry.registerPet("Buddy", 3, true);

        vm.prank(user2);
        petRegistry.registerPet("Max", 5, false);

        vm.prank(user1);
        (string memory name1, , ) = petRegistry.getPet();

        vm.prank(user2);
        (string memory name2, , ) = petRegistry.getPet();

        assertEq(name1, "Buddy");
        assertEq(name2, "Max");
    }

    function testFuzzRegisterPet(string memory name, uint256 age, bool isVaccinated) public {
        vm.assume(bytes(name).length > 0);
        vm.assume(age <= 30);

        vm.prank(user1);
        petRegistry.registerPet(name, age, isVaccinated);

        vm.prank(user1);
        (string memory returnedName, uint256 returnedAge, bool returnedVaccinated) = petRegistry.getPet();

        assertEq(returnedName, name);
        assertEq(returnedAge, age);
        assertEq(returnedVaccinated, isVaccinated);
    }
}
