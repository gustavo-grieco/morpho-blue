// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {TargetFunctions} from "./TargetFunctions.sol";
import {FoundryAsserts} from "@chimera/FoundryAsserts.sol";
import {MarketParams, Id, Position} from "../../src/interfaces/IMorpho.sol";
import "forge-std/console2.sol";
import {MarketParams} from "../../src/interfaces/IMorpho.sol";
import {MarketParamsLib} from "../../src/libraries/MarketParamsLib.sol";
import {console} from "forge-std/console.sol";

//forge test --match-test test_crytic
contract CryticToFoundry is Test, TargetFunctions, FoundryAsserts {
    using MarketParamsLib for MarketParams;

    function setUp() public {
        setup();
    }

    function test_marketDeploy() public {
        // clampedDeployMarket(1, 0, 1, 2, 1, 1e17, 1e18 - 1);
    }

    function test_simple() public {
        console.log(address(usdc));
        console.log(address(usdt));
        console.log(address(weth));
    }

    // function test_setFee() public {
    //     vm.warp(1641070800);
    //     clampedDeployMarket(1, 0, 1, 2, 1, 1e17, 19e17);
    //     clampedDeployMarket(2, 1, 2, 3, 0, 1e16, 19e15);
    //     MarketParams memory params = MarketParams({ loanToken: 0xc7183455a4C133Ae270771860664b6B7ec320bB1,
    // collateralToken: 0x2e234DAe75C793f67A35089C9d99245E1C58470b, oracle: 0xF62849F9A0B5Bf2913b396098F7c7019b51A820a,
    // irm: 0x1d1499e622D69689cdf9004d05Ec547d650Ff211, lltv: 100000000000000000});
    //     Id id = params.id();
    //     (,,,,uint128 lastUpdate,) = morpho.market(id);
    //     console.log(lastUpdate);
    //     console.log(marketNumber);
    //     console.log(currentMarket.collateralToken);
    //     switchMarket(0);
    //     console.log(currentMarket.collateralToken); //0x2e234DAe75C793f67A35089C9d99245E1C58470b
    //     morpho_setFee(1);
    // }
}
