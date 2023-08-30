// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Seed } from "contracts/Seed.sol";

contract Leaf {
    constructor() payable {
        Seed seed = Seed(msg.sender);
        address implementation = seed.implementation();
        assembly {
            let size := extcodesize(implementation)
            extcodecopy(implementation, 0, 0, size)
            return(0, size)
        }
    }
}