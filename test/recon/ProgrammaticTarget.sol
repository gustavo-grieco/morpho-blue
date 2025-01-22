// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "./BeforeAfter.sol";
import {Properties} from "./Properties.sol";
import {vm} from "@chimera/Hevm.sol";
import {MarketParams, Id, Position} from "../../src/interfaces/IMorpho.sol";
import {AddressGulper} from "./FuzzHelper.sol";
import {MarketParamsLib} from "../../src/libraries/MarketParamsLib.sol";


abstract contract ProgrammaticTarget is BaseTargetFunctions, AddressGulper, Properties {

    using MarketParamsLib for MarketParams;
    
    MarketParams[] markets;
    uint256 marketNumbers;

    function morpho_setOwner(address newOwner) public {
        //pass
        // vm.prank(address(this));
        morpho.setOwner(newOwner);
    }

    function mockOracle_setPrice(uint256 price) public {
        //pass
        oracle.setPrice(price);
    }

    function morpho_setAuthorization(address authorized, bool newIsAuthorized) public {
        morpho.setAuthorization(authorized, newIsAuthorized);
    }

    function morpho_deployMarket(uint256 collateral, uint256 loan, uint256 lltv) public {
        collateral %= 10;
        loan %= 10;

        lltv %= (1e18 - 1);
        require(collateral != loan, "same loan and collateral token");
        // morpho.enableIrm(address(irm));
        morpho.enableLltv(lltv);

        MarketParams memory params = MarketParams({
            loanToken: address(tokens[loan]),
            collateralToken: address(tokens[collateral]),
            oracle: address(oracle), //@note I am using the same oracle for all markets..
            irm: address(irm),
            lltv: 945000000000000000
        });

        tokens[collateral].approve(address(morpho), type(uint128).max);
        tokens[collateral].mint(address(this), type(uint128).max);

        tokens[loan].approve(address(morpho), type(uint128).max);
        tokens[loan].mint(address(address(this)), type(uint128).max);

        morpho.createMarket(params);
        marketNumbers++;
        markets.push(params);
    }

    function morpho_supplyCollateral(uint256 marketIndex, uint256 assets, address onBehalf) public {
        marketIndex %= (marketNumbers - 1);

        MarketParams memory params = markets[marketIndex];

        morpho.supplyCollateral(params, assets, onBehalf, "");
    }

    function morpho_supplyAssets(uint256 assets, address onBehalf, uint256 marketIndex) public {
        marketIndex %= (marketNumbers - 1);
        MarketParams memory params = markets[marketIndex];
        morpho.supply(params, assets, 0, onBehalf, "");
    }

    function morpho_supplyShares(uint256 shares, address onBehalf, uint256 marketIndex) public {
        marketIndex %= (marketNumbers - 1);
        MarketParams memory params = markets[marketIndex];
        morpho.supply(params, 0, shares, onBehalf, "");
    }

    function morpho_withdrawAsset(uint256 assets, address onBehalf, address receiver, uint256 marketIndex) public {
        marketIndex %= (marketNumbers - 1);
        MarketParams memory params = markets[marketIndex];

        morpho.withdraw(params, assets, 0, onBehalf, receiver);
    }

    function morpho_withdrawShares(uint256 shares, address onBehalf, uint256 marketIndex, address receiver) public {
        marketIndex %= (marketNumbers - 1);
        MarketParams memory params = markets[marketIndex];

        morpho.withdraw(params, 0, shares, onBehalf, receiver);
    }

    function morpho_withdrawCollateral(uint256 assets, address onBehalf, uint256 marketIndex, address receiver)
        public
    {
        marketIndex %= (marketNumbers - 1);
        MarketParams memory params = markets[marketIndex];

        morpho.withdrawCollateral(params, assets, onBehalf, receiver);
    }
    // The trade off of these function is that I have set a fixed lltv ?

    function morpho_borrowAssets(
        uint256 assets,
        address onBehalf,
        address receiver,
        uint256 marketIndex
    ) public {
        marketIndex %= (marketNumbers - 1);
        MarketParams memory params = markets[marketIndex];
        oracle.setPrice(2000267759191294354867396256538593928);

        morpho.borrow(params, assets, 0, onBehalf, receiver); //had to put 1 instead of assets
    }

    function morpho_borrowShares(uint256 shares, address onBehalf, address receiver, uint256 marketIndex) public {
        marketIndex %= (marketNumbers - 1);
        MarketParams memory params = markets[marketIndex];

        morpho.borrow(params, 0, shares, onBehalf, receiver);
    }

    function morpho_liquidateAssets(address borrower, uint256 marketIndex) public {
        marketIndex %= (marketNumbers - 1);
        MarketParams memory params = markets[marketIndex];
        uint256 seizedAssets;
        oracle.setPrice(0); // <= won't cover it unless I put it 
        Id id = params.id();
        (,, seizedAssets) = morpho.position(id, borrower);
        morpho.liquidate(params, borrower, seizedAssets, 0, "");
    }
    function morpho_liquidateShares(address borrower, uint256 marketIndex) public {
        marketIndex %= (marketNumbers - 1);
        MarketParams memory params = markets[marketIndex];
        uint256 seizedShares;
        oracle.setPrice(0);
        Id id = params.id();
        (,, seizedShares) = morpho.position(id, borrower);
        morpho.liquidate(params, borrower, 0, seizedShares, "");
    }

    function morpho_repayAssets(uint256 assets, address onBehalf, uint256 marketIndex) public {
        marketIndex %= (marketNumbers - 1);
        MarketParams memory params = markets[marketIndex];

        // morpho_borrowAssets(1, address(this), address(this), marketIndex);
        morpho.repay(params, assets, 0, address(this), "");
    }

    function morpho_repayShares(uint256 shares, address onBehalf, uint256 marketIndex) public {
        marketIndex %= (marketNumbers - 1);
        MarketParams memory params = markets[marketIndex];

        morpho.repay(params, 0, shares, onBehalf, "");
    }

    function morpho_flashLoan(uint256 amountBorrow, uint256 marketIndex) public {
        marketIndex %= (marketNumbers - 1);
        MarketParams memory params = markets[marketIndex];
        address collateral = params.collateralToken;

        morpho.flashLoan(collateral, amountBorrow, "");
    }

    function morpho_setFee(uint256 newFee, uint256 marketIndex) public {
        marketIndex %= (marketNumbers);

        MarketParams memory params = markets[marketIndex];

        newFee %= 0.25e18; //
        morpho.setFee(params, newFee);
    }

    function morpho_setFeeRecipient(address newFeeRecipient) public {
        // vm.prank(address(this)); //clamp
        morpho.setFeeRecipient(newFeeRecipient);
    }

    function morpho_accrueInterest(uint256 marketIndex, uint256 lltv) public {
        marketIndex %= (marketNumbers);
        MarketParams memory params = markets[marketIndex];

        morpho.accrueInterest(params);
    }
}
