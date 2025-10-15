// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

/**
 * @title PetRegistry
 * @dev Контракт для регистрации питомцев пользователей
 */
contract PetRegistry {
    address public owner;
    
    struct Pet {
        string name;
        uint age;
        bool isVaccinated;
    }
    
    mapping(address => Pet) public pets;
    mapping(address => bool) public registered;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function registerPet(string memory _name, uint _age, bool _isVaccinated) public {
        require(!registered[msg.sender], "User already has a registered pet");
        require(bytes(_name).length > 0, "Pet name cannot be empty");
        require(_age <= 30, "Pet age cannot exceed 30 years");
        
        pets[msg.sender] = Pet({
            name: _name,
            age: _age,
            isVaccinated: _isVaccinated
        });
        
        registered[msg.sender] = true;
    }
    
    function getPet() public view returns (string memory, uint, bool) {
        require(registered[msg.sender], "User has no registered pet");
        Pet memory pet = pets[msg.sender];
        return (pet.name, pet.age, pet.isVaccinated);
    }
    
    function updateVaccination(bool _newStatus) public {
        require(registered[msg.sender], "User has no registered pet");
        pets[msg.sender].isVaccinated = _newStatus;
    }
    
    function deletePet(address _user) public onlyOwner {
        require(registered[_user], "User has no registered pet");
        delete pets[_user];
        registered[_user] = false;
    }
}
