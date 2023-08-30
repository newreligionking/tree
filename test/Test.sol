// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "contracts/Leaf.sol";
import "contracts/Tree.sol";
import "contracts/Seed.sol";

// Simple contracts for testing div() function as leaf
contract Divider {
    function div(uint256 x, uint256 y) external pure returns (uint256 z) {
        z = x / y;
    }
}

// Simple contracts for testing mul() function as leaf
contract Multiplier {
    function mul(uint256 x, uint256 y) external pure returns (uint256 z) {
        return x * y;
    }
}

contract TestSeed is Seed {
    mapping(address => bool) public isAdmin;
    constructor(address[] memory admins) {
        for(uint256 i = 0; i < admins.length; i ++) isAdmin[admins[i]] = true;
    }
    function _authorize() internal view override {
        require(isAdmin[msg.sender], "Is not admin");
    }
}
contract MockAdmin {
    address immutable creator;
    constructor() { creator = msg.sender; }
    function doDeploy(Seed seed, bytes4 selector, address implementation) external {
        require(msg.sender == creator);
        seed.deploy(selector, implementation);
    }
    function check() external pure returns (bool) { return true; }
}
contract TreeTest {
    function test1() external returns (bytes4 debug) {
        address divider = address(new Divider());
        require(divider.code.length != 0, "No code");
        require(Divider(divider).div(20, 4) == 5, "No add up");
        address multiplier = address(new Multiplier());
        require(multiplier.code.length != 0, "No code");
        require(Multiplier(multiplier).mul(20, 4) == 80, "No add up");
        address mockAdmin = address(new MockAdmin());
        require(MockAdmin(mockAdmin).check(), "Check fails");
        address[] memory admins = new address[](3);
        admins[0] = address(this);
        admins[1] = msg.sender;
        admins[2] = mockAdmin;
        TestSeed seed = new TestSeed(admins);
        require(seed.isAdmin(address(this)), "Not admin");
        require(seed.isAdmin(mockAdmin), "Not admin");
        require(seed.isAdmin(msg.sender), "Not admin");
        debug = Divider.div.selector;
        seed.deploy(Divider.div.selector, divider);
        MockAdmin(mockAdmin).doDeploy(seed, Multiplier.mul.selector, multiplier);
        address tree = address(new Tree(address(seed)));
        uint256 divided = Divider(tree).div(20, 4);
        require(divided == 5, "Uh oh");
        uint256 multiplied = Multiplier(tree).mul(20, 4);
        require(multiplied == 80, "Oh no");
    }
}