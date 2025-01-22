// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseSetup} from "@chimera/BaseSetup.sol";
import {ExampleToken} from "./mocks/ExampleToken.sol";
import {Morpho} from "../../src/Morpho.sol";
import {ERC20Mock} from "../../src/mocks/ERC20Mock.sol";
import {OracleMock} from "../../src/mocks/OracleMock.sol";
import {IrmMock} from "../../src/mocks/IrmMock.sol";
import {MarketParams} from "../../src/interfaces/IMorpho.sol";
import {Test} from "forge-std/Test.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract Setup is BaseSetup {
    ExampleToken loanToken;
    ExampleToken collateralToken;
    Morpho morpho;
    address owner = address(this);
    OracleMock oracle;
    IrmMock irm;
    ERC20Mock mockToken;

    uint256 public lltv94 = 945000000000000000;

    function setup() internal virtual override {
        loanToken = new ExampleToken();
        collateralToken = new ExampleToken();
        morpho = new Morpho(owner);
        oracle = new OracleMock();
        irm = new IrmMock();

        // // deploy market ?

        morpho.enableIrm(address(irm));
        morpho.enableLltv(lltv94);

        MarketParams memory params = MarketParams({
            loanToken: address(loanToken),
            collateralToken: address(collateralToken),
            oracle: address(oracle),
            irm: address(irm),
            lltv: lltv94
        });

        morpho.createMarket(params);
        //@note should I set price ?
        /// could use flashborrower as well probably to be deployed here

        collateralToken.approve(address(morpho), type(uint128).max);
        collateralToken.mint(address(this), type(uint128).max);

        loanToken.approve(address(morpho), type(uint128).max);
        loanToken.mint(address(address(this)), type(uint128).max);
    }

    function onMorphoFlashLoan(uint256 assets, bytes calldata data) external {}
    function onMorphoSupply(uint256 assets, bytes32 data) external {}
}
