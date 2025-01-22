// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {TargetFunctions} from "./TargetFunctions.sol";
import {FoundryAsserts} from "@chimera/FoundryAsserts.sol";
import "forge-std/console2.sol";
import {MarketParams} from "../../src/interfaces/IMorpho.sol";
import {ProgrammaticTarget} from "./ProgrammaticTarget.sol";
import {console} from "forge-std/console.sol";

//forge test --match-test test_crytic
contract CryticToFoundry is Test, TargetFunctions, FoundryAsserts {
    function setUp() public {
        setup();
    }

    // function test_crytic() public {
    //     // TODO: add failing property tests here for debugging
    //     morpho.enableIrm(address(123));
    //     morpho.enableLltv(1e16);

    //     MarketParams memory params = MarketParams({
    //     loanToken: address(loanToken),
    //     collateralToken: address(collateralToken),
    //     oracle: address(oracle),
    //     irm: address(irm),
    //     lltv: 1e17
    //     });
    //     loanToken.approve(address(morpho), type(uint128).max);
    //     loanToken.mint(address(address(this)), type(uint128).max);

    //     morpho.supply(params, ,0, address(this), '');
    // }
    // function test_morpho_withdraw() public {
    //     morpho_withdraw(100e18, address(this), address(this));

    // }

    function test_borrow() public {
        MarketParams memory params = MarketParams({
            loanToken: address(loanToken),
            collateralToken: address(collateralToken),
            oracle: address(oracle),
            irm: address(irm),
            lltv: 945000000000000000
        });
        //         //address borrower, uint256 seizedAssets, bytes memory data, uint256 shares, uint256 price
        //         // borrow
        //         // setPrice => price crashes
        //         // liquidate
        morpho_supplyShares(1);
        morpho_supplyCollateral(1, address(this));
        oracle.setPrice(2000267759191294354867396256538593928);
        morpho_borrowAssets(1, address(this), address(this));
    }
    //         oracle.setPrice(0);
    //         morpho.liquidate(params, address(this), 1, 0, '');
    //     }

    // function test_repay() public {
    //     MarketParams memory params = MarketParams({
    //         loanToken: address(loanToken),
    //         collateralToken: address(collateralToken),
    //         oracle: address(oracle),
    //         irm: address(irm),
    //         lltv: 945000000000000000
    //     });
    //     //address borrower, uint256 seizedAssets, bytes memory data, uint256 shares, uint256 price
    //     // borrow
    //     // setPrice => price crashes
    //     // liquidate
    //     morpho_supplyShares(1);
    //     morpho_supplyCollateral(1, address(this));
    //     oracle.setPrice(2000267759191294354867396256538593928);
    //     morpho_borrowAssets(1, address(this), address(this));
    //     morpho.repay(params, 1, 0, address(this), "");
    // // // }
    // function test_borrow() public {
    //     morpho_deployMarket(5, 2, 1e18 - 1);
    //     morpho_deployMarket(5, 2, 1e18 - 1);
    //     // morpho_deployMarket(5, 2, 1e18 - 1);
    //     morpho_supplyCollateral(2, 100e18, address(this));
    //     morpho_supplyAssets(100e18, address(this), 2);
    //     morpho_borrowAsset(20e18 ,address(this), address(this),2);

    // }
}
