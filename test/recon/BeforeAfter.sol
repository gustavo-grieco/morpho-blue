// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {MarketParams, Id, Position} from "../../src/interfaces/IMorpho.sol";
import {Setup} from "./Setup.sol";
import {MarketParamsLib} from "../../src/libraries/MarketParamsLib.sol";


// ghost variables for tracking state variable values before and after function calls
abstract contract BeforeAfter is Setup {

    using MarketParamsLib for MarketParams;

    struct Vars {
        bool isHealthy;
    }

    Vars internal _before;
    Vars internal _after;

    function __before() internal {
        Id id = currentMarket.id();
        _before.isHealthy = morpho._isHealthy(currentMarket, id, borrower);
    }

    function __after() internal {
        Id id = currentMarket.id();
        _after.isHealthy = morpho._isHealthy(currentMarket, id, borrower);
    }

    modifier beforeAfter {
        __before();
        _;
        __after();
    }

//assert before after should be healthy

}
