// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseSetup} from "@chimera/BaseSetup.sol";
import {MarketParams, Id, Position} from "../../src/interfaces/IMorpho.sol";
import {ExampleToken} from "./mocks/ExampleToken.sol";
import {Morpho} from "../../src/Morpho.sol";
import {OracleMock} from "../../src/mocks/OracleMock.sol";
import {Test} from "forge-std/Test.sol";
import {vm} from "@chimera/Hevm.sol";
import {IrmMock} from "../../src/mocks/IrmMock.sol";


abstract contract Setup is BaseSetup {

    Morpho morpho;
    // USERS
    address owner = address(this);
    address bob = address(1);
    address patrick = address(2);
    address schneider = address(3);


    address[] players;
    ExampleToken[] tokens;
    OracleMock[] oracles;
    
    //TOKENS

    ExampleToken usdc;
    ExampleToken usdt;
    ExampleToken weth;
    
    //Switches

    uint256 marketNumber;
    MarketParams currentMarket;
    address receiver;
    address onBehalf;
    address borrower;

    //
    MarketParams[] markets;
    IrmMock[] irms;
    uint256[] enabledLltv;


    function setup() internal virtual override {
        morpho = new Morpho(owner);

        ///

        players.push(owner);
        players.push(bob);
        players.push(schneider);
        players.push(patrick);
        
        ///

        usdc = new ExampleToken();
        usdt = new ExampleToken();
        weth = new ExampleToken();

        tokens.push(usdc);
        tokens.push(usdt);
        tokens.push(weth);

        /// oracles

        OracleMock usdcOracle = new OracleMock();
        OracleMock usdtOracle = new OracleMock();
        OracleMock wethOracle = new OracleMock();

        oracles.push(usdcOracle);
        oracles.push(usdtOracle);
        oracles.push(wethOracle);
    }

    function onMorphoFlashLoan(uint256 assets, bytes calldata data) external {}
    function onMorphoSupply(uint256 assets, bytes32 data) external {}
}
