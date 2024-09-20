// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplyChain {
    // Enum to define different states in the supply chain
    enum State {
        Produced,
        Processed,
        Packaged,
        ForSale,
        Sold,
        Shipped,
        Received
    }

    // Structure for products
    struct Product {
        uint id;
        string name;
        State state;
        address owner;
    }

    // Structure for materials
    struct Material {
        string id;                // Unique identifier for the material
        string description;       // Description of the material
        address supplier;         // Address of the supplier
        bool isVerified;          // Verification status
        string status;            // Current status in the supply chain
    }

    // Mappings
    mapping(uint => Product) public products;
    mapping(string => Material) public materials;

    // Events
    event ProductStateChanged(uint productId, State state, address owner);
    event MaterialRegistered(string id, address supplier);
    event MaterialStatusUpdated(string id, string newStatus);
    event PaymentExecuted(address supplier, uint amount);

    // Contract owner
    address public owner;
    uint public productCount = 0;

    // Constructor to set the contract owner
    constructor() {
        owner = msg.sender; // Setting the deployer as the owner
    }

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier onlySupplier(string memory _id) {
        require(msg.sender == materials[_id].supplier, "Not authorized");
        _;
    }

    // Product functions
    function createProduct(string memory _name) public {
        productCount++;
        products[productCount] = Product(productCount, _name, State.Produced, msg.sender);
        emit ProductStateChanged(productCount, State.Produced, msg.sender);
    }

    function updateProductState(uint _productId, State _newState) public {
        require(products[_productId].owner == msg.sender, "Not the product owner");
        products[_productId].state = _newState;
        emit ProductStateChanged(_productId, _newState, msg.sender);
    }

    function transferProductOwnership(uint _productId, address _newOwner) public {
        require(products[_productId].owner == msg.sender, "Not the product owner");
        products[_productId].owner = _newOwner;
        emit ProductStateChanged(_productId, products[_productId].state, _newOwner);
    }

    // Material functions
    function registerMaterial(string memory _id, string memory _description) public {
        require(bytes(materials[_id].id).length == 0, "Material already exists");
        
        materials[_id] = Material({
            id: _id,
            description: _description,
            supplier: msg.sender,
            isVerified: false,
            status: "registered"
        });

        emit MaterialRegistered(_id, msg.sender);
    }

    function verifySupplier(string memory _id) public onlyOwner {
        require(bytes(materials[_id].id).length > 0, "Material not found");
        
        materials[_id].isVerified = true;
        emit MaterialStatusUpdated(_id, "verified");
    }

    function updateMaterialStatus(string memory _id, string memory _newStatus) public onlySupplier(_id) {
        require(bytes(materials[_id].id).length > 0, "Material not found");

        materials[_id].status = _newStatus;
        emit MaterialStatusUpdated(_id, _newStatus);
    }

    function executePayment(string memory _id, uint _amount) public onlyOwner {
        require(materials[_id].isVerified, "Material not verified");
        require(materials[_id].supplier != address(0), "Supplier not found");

        payable(materials[_id].supplier).transfer(_amount);
        emit PaymentExecuted(materials[_id].supplier, _amount);
    }

    function getMaterial(string memory _id) public view returns (Material memory) {
        return materials[_id];
    }

    // Withdraw contract balance (for owner)
    function withdrawBalance() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    // Fallback function to accept Ether
    receive() external payable {}
}
