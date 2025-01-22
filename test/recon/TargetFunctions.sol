// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "./BeforeAfter.sol";
import {Properties} from "./Properties.sol";
import {vm} from "@chimera/Hevm.sol";
import {MarketParams, Id, Position} from "../../src/interfaces/IMorpho.sol";
import {MarketParamsLib} from "../../src/libraries/MarketParamsLib.sol";
import {AddressGulper} from "./FuzzHelper.sol";

abstract contract TargetFunctions is BaseTargetFunctions, Properties {
    using MarketParamsLib for MarketParams;

    MarketParams parameter = MarketParams({
        loanToken: address(loanToken),
        collateralToken: address(collateralToken),
        oracle: address(oracle),
        irm: address(irm),
        lltv: lltv94
    }); // why I cannot use this ?

    function mockOracle_setPrice(uint256 price) public {
        //pass
        oracle.setPrice(price);
    }

    function morpho_setAuthorization(address authorized, bool newIsAuthorized) public {
        morpho.setAuthorization(authorized, newIsAuthorized);
        // pass
    }

    function morpho_setOwner(address newOwner) public {
        //pass
        vm.prank(address(this));
        morpho.setOwner(newOwner);
    }

    function morpho_setFee(uint256 newFee) public {
        MarketParams memory params = MarketParams({
            loanToken: address(loanToken),
            collateralToken: address(collateralToken),
            oracle: address(oracle),
            irm: address(irm),
            lltv: lltv94
        });

        newFee %= 0.25e18; //
        morpho.setFee(params, newFee);
    }

    function morpho_setFeeRecipient(address newFeeRecipient) public {
        //pass
        vm.prank(address(this)); //clamp
        morpho.setFeeRecipient(newFeeRecipient);
    }

    function morpho_enableLltv(uint256 lltv) public {
        lltv = lltv % (1e18 - 1);
        morpho.enableLltv(lltv);
        // canary passes
    }

    function morpho_supplyCollateral(uint256 assets, address onBehalf) public {
        MarketParams memory params = MarketParams({
            loanToken: address(loanToken),
            collateralToken: address(collateralToken),
            oracle: address(oracle),
            irm: address(irm),
            lltv: lltv94
        });
        morpho.supplyCollateral(params, assets, onBehalf, "");
    }

    function morpho_supplyAssets(uint256 assets) public {
        assets = assets % type(uint128).max; // less reverts ?
        //
        MarketParams memory params = MarketParams({
            loanToken: address(loanToken),
            collateralToken: address(collateralToken),
            oracle: address(oracle),
            irm: address(irm),
            lltv: lltv94
        });
        //
        morpho.supply(params, assets, 0, address(this), "");
    }

    function morpho_supplyShares(uint256 shares) public {
        shares = shares % type(uint128).max; // less reverts ?
        //
        MarketParams memory params = MarketParams({
            loanToken: address(loanToken),
            collateralToken: address(collateralToken),
            oracle: address(oracle),
            irm: address(irm),
            lltv: lltv94
        });
        //
        morpho.supply(params, 0, shares, address(this), "");
    }

    function morpho_withdrawAsset(uint256 assets, address onBehalf, address receiver) public {
        MarketParams memory params = MarketParams({
            loanToken: address(loanToken),
            collateralToken: address(collateralToken),
            oracle: address(oracle),
            irm: address(irm),
            lltv: lltv94
        });

        morpho.withdraw(params, assets, 0, onBehalf, receiver);
    }

    function morpho_withdrawShares(uint256 shares, address onBehalf, address receiver) public {
        MarketParams memory params = MarketParams({
            loanToken: address(loanToken),
            collateralToken: address(collateralToken),
            oracle: address(oracle),
            irm: address(irm),
            lltv: lltv94
        });

        morpho.withdraw(params, 0, shares, onBehalf, receiver);
    }

    function morpho_withdrawCollateral(uint256 assets, address onBehalf, address receiver) public {
        MarketParams memory params = MarketParams({
            loanToken: address(loanToken),
            collateralToken: address(collateralToken),
            oracle: address(oracle),
            irm: address(irm),
            lltv: lltv94
        });
        morpho.withdrawCollateral(params, assets, onBehalf, receiver);
    }
    // The trade off of these function is that I have set a fixed lltv ?

    function morpho_borrowAssets(uint256 assets, address onBehalf, address receiver) public {
        MarketParams memory params = MarketParams({
            loanToken: address(loanToken),
            collateralToken: address(collateralToken),
            oracle: address(oracle),
            irm: address(irm),
            lltv: lltv94
        });
        // morpho_supplyShares(1);
        // morpho_supplyCollateral(1, address(this));
        // oracle.setPrice(2000267759191294354867396256538593928);
        morpho.borrow(params, assets, 0, address(this), address(this));
    } // had to guide it at first, setting assets to 1

    function morpho_borrowShares(uint256 shares, address onBehalf, address receiver) public {
        MarketParams memory params = MarketParams({
            loanToken: address(loanToken),
            collateralToken: address(collateralToken),
            oracle: address(oracle),
            irm: address(irm),
            lltv: lltv94
        });
        morpho.borrow(params, 0, shares, address(this), address(this));
    }

    function morpho_liquidateAssets(address borrower, uint256 toSeize) public {
        MarketParams memory params = MarketParams({
            loanToken: address(loanToken),
            collateralToken: address(collateralToken),
            oracle: address(oracle),
            irm: address(irm),
            lltv: lltv94
        });
        Id id = params.id();
        (,, toSeize) = morpho.position(id, borrower); //why it doesn't find explore the whole function without this ?
        morpho.liquidate(params, borrower, toSeize, 0, "");
    }

    function morpho_liquidateShares(address borrower, uint256 seizedShares) public {
        MarketParams memory params = MarketParams({
            loanToken: address(loanToken),
            collateralToken: address(collateralToken),
            oracle: address(oracle),
            irm: address(irm),
            lltv: lltv94
        });

        morpho.liquidate(params, borrower, 0, seizedShares, "");
    }

    function morpho_repayShares(uint256 shares, address onBehalf) public {
        MarketParams memory params = MarketParams({
            loanToken: address(loanToken),
            collateralToken: address(collateralToken),
            oracle: address(oracle),
            irm: address(irm),
            lltv: lltv94
        });
        morpho.repay(params, 0, shares, onBehalf, "");
    }

    function morpho_repayAssets(uint256 assets, address onBehalf) public {
        MarketParams memory params = MarketParams({
            loanToken: address(loanToken),
            collateralToken: address(collateralToken),
            oracle: address(oracle),
            irm: address(irm),
            lltv: lltv94
        });
        morpho.repay(params, assets, 0, onBehalf, ""); //to change
    }

    function morpho_flashLoan(uint256 amountborrow) public {
        morpho.flashLoan(address(collateralToken), amountborrow, "");
    }

    function morpho_accrueInterest() public {
        MarketParams memory params = MarketParams({
            loanToken: address(loanToken),
            collateralToken: address(collateralToken),
            oracle: address(oracle),
            irm: address(irm),
            lltv: lltv94
        });
        morpho.accrueInterest(params);
    }
}
