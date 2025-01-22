// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {ExampleToken} from "./mocks/ExampleToken.sol";

contract AddressGulper {
    address player1 = address(1);
    address player2 = address(2);
    address player3 = address(3);
    address player4 = address(4);
    address player5 = address(5);
    address player6 = address(6);
    address player7 = address(7);
    address player8 = address(8);
    address player9 = address(9);

    address[] public players;
    ExampleToken[] public tokens;

    ExampleToken token1;
    ExampleToken token2;
    ExampleToken token3;
    ExampleToken token4;
    ExampleToken token5;
    ExampleToken token6;
    ExampleToken token7;
    ExampleToken token8;
    ExampleToken token9;
    ExampleToken token10;

    constructor() {
        players = [player1, player2, player3, player4, player5, player6, player7, player8, player9];
        token1 = new ExampleToken();
        token2 = new ExampleToken();
        token3 = new ExampleToken();
        token4 = new ExampleToken();
        token5 = new ExampleToken();
        token6 = new ExampleToken();
        token7 = new ExampleToken();
        token8 = new ExampleToken();
        token9 = new ExampleToken();
        token10 = new ExampleToken();

        tokens = [token1, token2, token3, token4, token5, token6, token7, token8, token9, token10];
    }
}
