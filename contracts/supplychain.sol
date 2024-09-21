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
        Received,
        Delivered
    }

    // Structure for products
    struct Product {
        uint256 id;
        string name;
        State state;
        address owner;
    }

    // Structure for materials
    struct Material {
        string id; // Unique identifier for the material
        string description; // Description of the material
        address supplier; // Address of the supplier
        bool isVerified; // Verification status
        string status; // Current status in the supply chain
    }

    // Structure for logistics tracking
    struct LogisticCheckpoint {
        string location;
        uint256 timestamp;
        string status;
    }

    // Mappings
    mapping(uint256 => Product) public products;
    mapping(string => Material) public materials;
    mapping(uint256 => LogisticCheckpoint[]) public productLogistics; // Tracking logistics by product ID

    // Events
    event ProductStateChanged(uint256 productId, State state, address owner);
    event MaterialRegistered(string id, address supplier);
    event MaterialStatusUpdated(string id, string newStatus);
    event PaymentExecuted(address supplier, uint256 amount);
    event LogisticCheckpointRecorded(
        uint256 productId,
        string location,
        string status,
        uint256 timestamp
    );
    event SupplierVerified(address supplier);

    // Contract owner
    address public owner;
    uint256 public productCount = 0;

    // Mappings for supplier verification
    mapping(address => bool) public verifiedSuppliers;

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

    modifier onlyProductOwner(uint256 _productId) {
        require(
            products[_productId].owner == msg.sender,
            "Not the product owner"
        );
        _;
    }

    modifier onlyVerifiedSupplier() {
        require(verifiedSuppliers[msg.sender], "Supplier not verified");
        _;
    }

    // Product functions
    function createProduct(string memory _name) public {
        productCount++;
        products[productCount] = Product(
            productCount,
            _name,
            State.Produced,
            msg.sender
        );
        emit ProductStateChanged(productCount, State.Produced, msg.sender);
    }

    function updateProductState(uint256 _productId, State _newState)
        public
        onlyProductOwner(_productId)
    {
        products[_productId].state = _newState;
        emit ProductStateChanged(_productId, _newState, msg.sender);
    }

    function transferProductOwnership(uint256 _productId, address _newOwner)
        public
        onlyProductOwner(_productId)
    {
        products[_productId].owner = _newOwner;
        emit ProductStateChanged(
            _productId,
            products[_productId].state,
            _newOwner
        );
    }

    // Material functions
    function registerMaterial(string memory _id, string memory _description)
        public
        onlyVerifiedSupplier
    {
        require(
            bytes(materials[_id].id).length == 0,
            "Material already exists"
        );

        materials[_id] = Material({
            id: _id,
            description: _description,
            supplier: msg.sender,
            isVerified: false,
            status: "registered"
        });

        emit MaterialRegistered(_id, msg.sender);
    }

    function updateMaterialStatus(string memory _id, string memory _newStatus)
        public
        onlySupplier(_id)
    {
        require(bytes(materials[_id].id).length > 0, "Material not found");
        materials[_id].status = _newStatus;
        emit MaterialStatusUpdated(_id, _newStatus);
    }

    function verifySupplier(address _supplier) public onlyOwner {
        require(_supplier != address(0), "Invalid supplier address");
        verifiedSuppliers[_supplier] = true;
        emit SupplierVerified(_supplier);
    }

    function executePayment(string memory _id, uint256 _amount)
        public
        onlyOwner
    {
        require(materials[_id].isVerified, "Material not verified");
        require(materials[_id].supplier != address(0), "Supplier not found");
        payable(materials[_id].supplier).transfer(_amount);
        emit PaymentExecuted(materials[_id].supplier, _amount);
    }

    function getMaterial(string memory _id)
        public
        view
        returns (Material memory)
    {
        return materials[_id];
    }

    // Logistics functions
    function recordLogisticCheckpoint(
        uint256 _productId,
        string memory _location,
        string memory _status
    ) public onlyProductOwner(_productId) {
        require(
            products[_productId].state == State.Shipped ||
                products[_productId].state == State.Received,
            "Product not in transit"
        );

        LogisticCheckpoint memory checkpoint = LogisticCheckpoint({
            location: _location,
            timestamp: block.timestamp,
            status: _status
        });
        // require(, "Insufficient balance");

        if (products[_productId].state == State.Received) {
            withdrawBalance(msg.sender);
        }
        productLogistics[_productId].push(checkpoint);
        emit LogisticCheckpointRecorded(
            _productId,
            _location,
            _status,
            block.timestamp
        );
    }

    function getLogisticsHistory(uint256 _productId)
        public
        view
        returns (LogisticCheckpoint[] memory)
    {
        return productLogistics[_productId];
    }

    // Withdraw contract balance (for owner)
    function withdrawBalance(address sender) internal returns (bool) {
        payable(sender).transfer(1000000000000000);
        return true;
    }

    // Fallback function to accept Ether
    receive() external payable {}
}
