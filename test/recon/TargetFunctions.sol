// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "./BeforeAfter.sol";
import {Properties} from "./Properties.sol";
import {vm} from "@chimera/Hevm.sol";
import {MarketParams, Id, Position} from "../../src/interfaces/IMorpho.sol";
import {MarketParamsLib} from "../../src/libraries/MarketParamsLib.sol";
import {ExampleToken} from "./mocks/ExampleToken.sol";
import {OracleMock} from "../../src/mocks/OracleMock.sol";
import {IrmMock} from "../../src/mocks/IrmMock.sol";
import {console} from "forge-std/console.sol";
import {IOracle} from "../../src/interfaces/IOracle.sol";
import {Canaries} from "./Canaries.sol";

abstract contract TargetFunctions is BaseTargetFunctions, Properties, Canaries {
    using MarketParamsLib for MarketParams;


    // Switch Functions
    function swichBorrower(uint256 index) public {
        index %= players.length;
        borrower = players[index];
    }

    function switchOnBehalf(uint256 index) public {
        index %= players.length;
        onBehalf = players[index];
    }

    function switchReceiver(uint256 index) public {
        index %= players.length;
        receiver = players[index];
    }


    function switchMarket(uint256 index) public {
        index %= (marketNumber);
        currentMarket = markets[index];
    }
    // the rest
    function mint(uint256 tokenIndex, uint256 amount) public {
        tokenIndex %= (tokens.length);
        tokens[tokenIndex].mint(address(this), amount);
        tokens[tokenIndex].approve(address(morpho), amount);
    }

    function deployIRM() public {
        //market must have its own coll, debt, one oracle, one IRM
        IrmMock irm = new IrmMock();
        irms.push(irm);
    } //NOTE how do we track how many markets are actually being deployed ?

    function morpho_setOwner(address newOwner) public {
        morpho.setOwner(newOwner);
    }

    function morpho_setFeeRecipient(address newFeeRecipient) public {
        morpho.setFeeRecipient(newFeeRecipient);
    }

    function morpho_enableLltv(uint256 lltv) public {
        lltv %= (1e18);
        morpho.enableLltv(lltv);
        enabledLltv.push(lltv);
    }

    function morpho_enableIrm(uint256 irmIndex) public {
        irmIndex %= irms.length;
        morpho.enableIrm(address(irms[irmIndex]));
    }

    function morpho_setAuthorization(bool newIsAuthorized) public {
        morpho.setAuthorization(onBehalf, newIsAuthorized);
    }

    function morpho_deployMarket(uint256 irmIndex, uint256 collateralIndex, uint256 loanIndex, uint256 lltvIndex)
        public
    {
        loanIndex %= (tokens.length);
        collateralIndex %= (tokens.length);
        irmIndex %= (irms.length);
        lltvIndex %= (enabledLltv.length);

        require(loanIndex != collateralIndex, "same collateral and loan");
        address oracle = address(oracles[collateralIndex]);

        MarketParams memory params = MarketParams({
            loanToken: address(tokens[loanIndex]),
            collateralToken: address(tokens[collateralIndex]),
            oracle: address(oracles[collateralIndex]),
            irm: address(irms[irmIndex]),
            lltv: enabledLltv[lltvIndex]
        });

        morpho.createMarket(params);

        marketNumber++;

        markets.push(params);

        currentMarket = params;

        // populateMapping(tokenForMarketCombination, tokens[collateralIndex], tokens[loanIndex]);
        // canary_all_TokensUsed();
    }

    function morpho_flashLoan(uint256 amountBorrow) public {
        address collateral = currentMarket.collateralToken;
        morpho.flashLoan(collateral, amountBorrow, "");
    }

    function morpho_setFee(uint256 newFee) public {
        newFee %= 0.25e18; //NOTE Clamped
        morpho.setFee(currentMarket, newFee);
    }

    function morpho_setPrice(uint256 price) public {
        OracleMock currentOracle = OracleMock(currentMarket.oracle);
        currentOracle.setPrice(price);
    }

    function morpho_supplyCollateral(uint256 assets) public beforeAfter {
        morpho.supplyCollateral(currentMarket, assets, onBehalf, "");
    }

    function morpho_supply(uint256 assets, uint256 shares) public beforeAfter {
        morpho.supply(currentMarket, assets, shares, address(this), ""); //NOTE address has been clamped
    }

    function morpho_clamped_supplyAssets(uint256 assets) public beforeAfter {
        morpho_supply(assets, 0);
    }

    function morpho_clamped_supplyShares(uint256 shares) public beforeAfter {
        morpho_supply(0, shares);
    }

    function morpho_withdrawCollateral(uint256 assets) public beforeAfter {
        morpho.withdrawCollateral(currentMarket, assets, onBehalf, receiver);
    }

    function morpho_borrow(uint256 assets, uint256 shares) public beforeAfter {
        morpho.borrow(currentMarket, assets, shares, onBehalf, receiver);
    }

    function morpho_clamped_borrowAssets(uint256 assets) public beforeAfter {
        morpho_borrow(assets, 0);
    }

    // function morpho_macro_borrowAssets(uint256 price, uint256 supplyAmount, uint256 borrowA) public {
    //     morpho_supplyCollateral(supplyAmount); // is this macro ? We don't want it
    //     morpho_clamped_borrowAssets(borrowA); //NOTE can we get this path within 1mill runs ? 
    // }

    function morpho_clamped_borrowShares(uint256 shares) public beforeAfter {
        morpho_borrow(0, shares);
    }

    function morpho_withdrawAsset(uint256 assets) public beforeAfter {
        morpho.withdraw(currentMarket, assets, 0, onBehalf, receiver);
    }

    function morpho_withdrawShares(uint256 shares) public beforeAfter {
        morpho.withdraw(currentMarket, 0, shares, onBehalf, receiver);
    }

    function morpho_repay(uint256 assets, uint256 shares) public beforeAfter {
        morpho.repay(currentMarket, assets, shares, onBehalf, ""); 
    }

    function morpho_clamped_repayAssets(uint256 assets) public beforeAfter {
        morpho_repay(assets, 0);
    }

    // function morpho_macro_repayAssets() public {
    //     morpho_clamped_repayAssets(1); //NOTE MACRO
    // }

    function morpho_clamped_repayShares(uint256 shares) public beforeAfter {
        morpho_repay(0, shares);
    }

    function morpho_accrueInterest() public beforeAfter {
        morpho.accrueInterest(currentMarket);
    }

    function morpho_liquidate(uint256 assets, uint256 shares) public beforeAfter {
        morpho.liquidate(currentMarket, borrower, assets, shares, ""); //NOTE clamped address
    }

    function morpho_clamped_liquidateAssets(uint256 assets) public beforeAfter {
        morpho_liquidate(assets, 0);
    }

    function morpho_macro_liquidateAssets(uint256 price, uint256 assets) public beforeAfter {
        morpho_setPrice(price);
        morpho_clamped_liquidateAssets(assets);

        populateMapping(liquidated, ExampleToken(currentMarket.collateralToken), ExampleToken(currentMarket.loanToken));
        canary_all_Tokens_liquidated(); //this didn't hit in 10 million
        //will it ever hit ? I guess eventually
    }

    function morpho_superSet_macroLiquidate(uint256 price) public beforeAfter {
        Id id = currentMarket.id();
        (,, uint256 seizedAssets) = morpho.position(id, borrower); 
        morpho_macro_liquidateAssets(price, seizedAssets); //NOTE reached within 2 million runs
    }

    function morpho_clamped_liquidateShares(uint256 shares) public beforeAfter {
        morpho_liquidate(0, shares); //NOTE Reached at 2.5 mill runs
    }
}
