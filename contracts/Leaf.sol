// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { BaseDeployer } from "contracts/BaseDeployer.sol";

contract Leaf {
    constructor() payable {
        BaseDeployer deployer = BaseDeployer(msg.sender);
        address implementation = deployer.implementation();
        assembly {
            let size := extcodesize(implementation)
            extcodecopy(implementation, 0, 0, size)
            return(0, size)
        }
    }
}