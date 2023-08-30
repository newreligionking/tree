// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Leaf } from "contracts/Leaf.sol";

abstract contract BaseDeployer {
    address public implementation;
    event NewLeaf(bytes4 indexed selector, address indexed implementation);
    function deploy(bytes4 selector, address _implementation) external payable returns (address deployed) {
        _authorize();
        implementation = _implementation;
        bytes32 salt = bytes32(selector);
        deployed = address(new Leaf{salt: salt, value: msg.value}());
        if (deployed == address(0)) revert();
        emit NewLeaf(selector, _implementation);
    }
    function _authorize() internal virtual;
}