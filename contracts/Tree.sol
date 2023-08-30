// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Leaf } from "contracts/Leaf.sol";

contract Tree {
    bytes32 constant leafCodeHash = keccak256(type(Leaf).creationCode);
    address immutable seed;
    constructor(address s) { seed = s; }
    fallback(bytes calldata) external payable returns (bytes memory) {
        bytes4 selector = msg.sig;
        address target = c2a(bytes32(selector), leafCodeHash, seed);
        (bool success, bytes memory output) = target.delegatecall(msg.data);
        if (success) return output;
        revert(string(output));
    }
}
function c2a(bytes32 salt, bytes32 initCodeHash, address creator) pure returns (address account) {
    /// @solidity memory-safe-assembly
    assembly {
        let ptr := mload(0x40) // Get free memory pointer
        mstore(add(ptr, 0x40), initCodeHash)
        mstore(add(ptr, 0x20), salt)
        mstore(ptr, creator) // Right-aligned with 12 preceding garbage bytes
        let start := add(ptr, 0x0b) // The hashed data starts at the final garbage byte which we will set to 0xff
        mstore8(start, 0xff)
        account := keccak256(start, 85)
    }
}