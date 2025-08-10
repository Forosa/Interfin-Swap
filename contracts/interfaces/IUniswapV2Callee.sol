// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Interface for Uniswap V2 flash swap callback
interface IUniswapV2Callee {
    /**
     * @notice Called to `msg.sender` after executing a flash swap via IUniswapV2Pair#swap.
     * @dev You must repay the tokens borrowed, plus a fee, within this call.
     * @param sender The initiator of the swap.
     * @param amount0 The amount of token0 borrowed.
     * @param amount1 The amount of token1 borrowed.
     * @param data Arbitrary data passed from the caller.
     */
    function uniswapV2Call(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external;
}