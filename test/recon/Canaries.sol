// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Properties} from "./Properties.sol";
import {vm} from "@chimera/Hevm.sol";
import {ExampleToken} from "./mocks/ExampleToken.sol";

abstract contract Canaries is Properties {
    //      coll                      loan
    mapping(ExampleToken => mapping(ExampleToken => bool)) tokenForMarketCombination;
    mapping(ExampleToken => mapping(ExampleToken => bool)) liquidated;

    function populateMapping(
        mapping(ExampleToken => mapping(ExampleToken => bool)) storage targetMapping,
        ExampleToken tokenA,
        ExampleToken tokenB
    ) internal {
        targetMapping[tokenA][tokenB] = true;
    }

    function allTokensUsed() public returns (bool) {
        if (
            tokenForMarketCombination[usdc][weth] == true && tokenForMarketCombination[usdc][usdt] == true
                && tokenForMarketCombination[usdt][weth] == true
        ) return true;
    }

    function allTokenLiquidated() public returns (bool) {
        if (liquidated[usdc][weth] == true && liquidated[usdc][usdt] == true ) {
            return true;
        }
    }
    //     function allTokenLiquidated() public returns (bool) {
    //     if (liquidated[usdc][weth] == true || liquidated[weth][usdc] == true && liquidated[usdc][usdt] == true || liquidated[usdt][usdc] == true) {
    //         return true;
    //     }
    // }
    //&& liquidated[usdt][weth] == true

    function canary_all_TokensUsed() public {
        if (allTokensUsed()) t(false, "all tokens used canary");
    }

    function canary_all_Tokens_liquidated() public {
        if (allTokenLiquidated()) t(false, "all tokens liquidated canary");
    }
    
}

