// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {TargetFunctions} from "./TargetFunctions.sol";
import {CryticAsserts} from "@chimera/CryticAsserts.sol";
import {ProgrammaticTarget} from "./ProgrammaticTarget.sol";
// echidna . --contract CryticTester --config echidna.yaml
// medusa fuzz
// echidna . --contract CryticTester --config echidna.yaml --format text --test-limit 1000000

// contract CryticTester is TargetFunctions, CryticAsserts {
contract CryticTester is ProgrammaticTarget, CryticAsserts {
    constructor() payable {
        setup();
    }
}
