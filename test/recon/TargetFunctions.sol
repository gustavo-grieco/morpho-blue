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
    constructor() {
      deployIRM();
      deployIRM();
      deployIRM();
    }

    using MarketParamsLib for MarketParams;
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

    function deployIRM() internal {
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
        morpho.enableLltv(lltv);
        enabledLltv.push(lltv);
    }

    function morpho_enableIrm(uint256 irmIndex) public {
        irmIndex %= irms.length;
        morpho.enableIrm(address(irms[irmIndex]));
    }

    function morpho_setAuthorization(uint256 indexOnBehalf, bool newIsAuthorized) public {
        indexOnBehalf %= players.length;
        address onBehalf = players[indexOnBehalf];
        morpho.setAuthorization(onBehalf, newIsAuthorized);
    }

    function morpho_deployMarket(uint256 irmIndex, uint256 collateralIndex, uint256 loanIndex, uint256 lltvIndex)
        public
    {
        require(marketNumber < 4);
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
        morpho.setFee(currentMarket, newFee);
    }

    function morpho_setPrice(uint256 price) public {
        OracleMock currentOracle = OracleMock(currentMarket.oracle);
        currentOracle.setPrice(price);
    }

    function morpho_supplyCollateral(uint256 assets, uint256 indexOnBehalf) public {
        indexOnBehalf %= players.length;
        address onBehalf = players[indexOnBehalf];
        borrower = onBehalf;
        __before(); 
        morpho.supplyCollateral(currentMarket, assets, onBehalf, "");
        __after();
    }

    function morpho_supply(uint256 assets, uint256 shares, uint256 indexOnBehalf) public {
        indexOnBehalf %= players.length;
        address onBehalf = players[indexOnBehalf];
        borrower = onBehalf;
        __before();        
        morpho.supply(currentMarket, assets, shares, onBehalf, "");
        __after();
    }

    function morpho_withdrawCollateral(uint256 assets, uint256 indexOnBehalf, uint256 indexReceiver) public {
        indexOnBehalf %= players.length;
        address onBehalf = players[indexOnBehalf];

        indexReceiver %= players.length;
        address receiver = players[indexReceiver];

        borrower = onBehalf;
        __before();
        morpho.withdrawCollateral(currentMarket, assets, onBehalf, receiver);
        __after();
    }

    function morpho_borrow(uint256 assets, uint256 shares, uint256 indexReceiver, uint256 indexOnBehalf) public {
        indexOnBehalf %= players.length;
        address onBehalf = players[indexOnBehalf];

        indexReceiver %= players.length;
        address receiver = players[indexReceiver];

        borrower = onBehalf;
        __before();
        morpho.borrow(currentMarket, assets, shares, onBehalf, receiver);
        __after();
    }

    function morpho_withdrawShares(uint256 shares, uint256 assets, uint256 indexReceiver, uint256 indexOnBehalf) public {
        indexOnBehalf %= players.length;
        address onBehalf = players[indexOnBehalf];

        indexReceiver %= players.length;
        address receiver = players[indexReceiver];

        borrower = onBehalf;
        __before();
        morpho.withdraw(currentMarket, assets, shares, onBehalf, receiver);
        __after();
    }

    function morpho_repay(uint256 assets, uint256 shares, uint256 indexOnBehalf) public {
        indexOnBehalf %= players.length;
        address onBehalf = players[indexOnBehalf];
        borrower = onBehalf;
        __before();
        morpho.repay(currentMarket, assets, shares, onBehalf, ""); 
        __after();
    }

    function morpho_accrueInterest() public {
        morpho.accrueInterest(currentMarket);
    }

    function morpho_macro_liquidateAssets(uint256 price, uint256 indexBorrower, uint256 assets, uint256 shares) public {
        morpho_setPrice(price);
        indexBorrower %= players.length;
        borrower = players[indexBorrower];
        //__before();
        morpho.liquidate(currentMarket, borrower, assets, shares, ""); 
        assert(false);
        //__after();
    }
}
