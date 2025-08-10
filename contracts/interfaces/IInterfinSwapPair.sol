// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IInterfinSwapPair {
    function initialize(address token0, address token1) external;
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    // Add any other functions/events you call from factory or router
}