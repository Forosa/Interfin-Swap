// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IInterfinSwapFactory.sol";
import "../interfaces/IInterfinSwapPair.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library InterfinSwapLibrary {
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "InterfinSwapLibrary: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "InterfinSwapLibrary: ZERO_ADDRESS");
        return (token0, token1);
    }

    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        // !! IMPORTANT !! Replace with your actual InterfinSwapPair INIT_CODE_HASH
        pair = address(uint160(uint(keccak256(abi.encodePacked(
            hex'ff',
            factory,
            keccak256(abi.encodePacked(token0, token1)),
            hex'YOUR_INIT_CODE_HASH_HERE'
        )))));
        return pair;
    }

    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        address pair = IInterfinSwapFactory(factory).getPair(tokenA, tokenB);
        require(pair != address(0), "InterfinSwapLibrary: PAIR_NOT_FOUND");
        (uint reserve0, uint reserve1) = IInterfinSwapPair(pair).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
        return (reserveA, reserveB);
    }

    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, "InterfinSwapLibrary: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "InterfinSwapLibrary: INSUFFICIENT_LIQUIDITY");
        amountB = (amountA * reserveB) / reserveA;
        return amountB;
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, "InterfinSwapLibrary: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "InterfinSwapLibrary: INSUFFICIENT_LIQUIDITY");
        uint amountInWithFee = amountIn * 997;
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = reserveIn * 1000 + amountInWithFee;
        amountOut = numerator / denominator;
        return amountOut;
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, "InterfinSwapLibrary: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "InterfinSwapLibrary: INSUFFICIENT_LIQUIDITY");
        uint numerator = reserveIn * amountOut * 1000;
        uint denominator = (reserveOut - amountOut) * 997;
        amountIn = (numerator / denominator) + 1;
        return amountIn;
    }

    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, "InterfinSwapLibrary: INVALID_PATH");
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i = 0; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
        return amounts;
    }

    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, "InterfinSwapLibrary: INVALID_PATH");
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
        return amounts;
    }
}

interface IWETH {
    function deposit() external payable;
    function withdraw(uint) external;
    function transfer(address to, uint value) external returns (bool);
    function balanceOf(address owner) external view returns (uint);
}

contract InterfinSwapRouter02 {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _WETH) {
        factory = _factory;
        WETH = _WETH;
    }

    receive() external payable {
        require(msg.sender == WETH, "Router: ONLY_WETH");
    }

    // Add liquidity (token/token)
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to
    ) public returns (uint amountA, uint amountB, uint liquidity) {
        (address token0, address token1) = InterfinSwapLibrary.sortTokens(tokenA, tokenB);
        address pair = IInterfinSwapFactory(factory).getPair(tokenA, tokenB);
        if (pair == address(0)) {
            pair = IInterfinSwapFactory(factory).createPair(tokenA, tokenB);
        }
        (uint reserveA, uint reserveB) = InterfinSwapLibrary.getReserves(factory, tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint amountBOptimal = InterfinSwapLibrary.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired && amountBOptimal >= amountBMin) {
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = InterfinSwapLibrary.quote(amountBDesired, reserveB, reserveA);
                require(amountAOptimal <= amountADesired && amountAOptimal >= amountAMin, "Router: INSUFFICIENT_A_AMOUNT");
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
        IERC20(tokenA).transferFrom(msg.sender, pair, amountA);
        IERC20(tokenB).transferFrom(msg.sender, pair, amountB);
        liquidity = IInterfinSwapPair(pair).addLiquidity(uint112(amountA), uint112(amountB));
        IERC20(pair).transfer(to, liquidity);
    }

    // Add liquidity with BNB (ETH)
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity) {
        (amountToken, amountETH, liquidity) = _addLiquidityETH(token, amountTokenDesired, amountTokenMin, amountETHMin, to, msg.value);
    }

    function _addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint value
    ) private returns (uint amountToken, uint amountETH, uint liquidity) {
        (amountToken, amountETH, liquidity) = addLiquidity(
            token,
            WETH,
            amountTokenDesired,
            value,
            amountTokenMin,
            amountETHMin,
            to
        );
        IWETH(WETH).deposit{value: amountETH}();
        require(IWETH(WETH).transfer(InterfinSwapLibrary.pairFor(factory, token, WETH), amountETH), "Router: WETH_TRANSFER_FAILED");
    }

    // Remove liquidity (token/token)
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to
    ) external returns (uint amountA, uint amountB) {
        address pair = InterfinSwapLibrary.pairFor(factory, tokenA, tokenB);
        IERC20(pair).transferFrom(msg.sender, pair, liquidity);
        (amountA, amountB) = IInterfinSwapPair(pair).removeLiquidity(liquidity);
        require(amountA >= amountAMin, "Router: INSUFFICIENT_A_AMOUNT");
        require(amountB >= amountBMin, "Router: INSUFFICIENT_B_AMOUNT");
        IERC20(tokenA).transfer(to, amountA);
        IERC20(tokenB).transfer(to, amountB);
    }

    // Remove liquidity with BNB (ETH)
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to
    ) external returns (uint amountToken, uint amountETH) {
        address pair = InterfinSwapLibrary.pairFor(factory, token, WETH);
        IERC20(pair).transferFrom(msg.sender, pair, liquidity);
        (amountToken, amountETH) = IInterfinSwapPair(pair).removeLiquidity(liquidity);
        require(amountToken >= amountTokenMin, "Router: INSUFFICIENT_TOKEN_AMOUNT");
        require(amountETH >= amountETHMin, "Router: INSUFFICIENT_ETH_AMOUNT");
        IERC20(token).transfer(to, amountToken);
        IWETH(WETH).withdraw(amountETH);
        payable(to).transfer(amountETH);
    }

    // Swap exact tokens for tokens
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to
    ) external returns (uint[] memory amounts) {
        require(path.length >= 2, "Router: INVALID_PATH");
        amounts = InterfinSwapLibrary.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "Router: INSUFFICIENT_OUTPUT_AMOUNT");
        IERC20(path[0]).transferFrom(msg.sender, InterfinSwapLibrary.pairFor(factory, path[0], path[1]), amounts[0]);
        _swap(amounts, path, to);
    }

    // Swap exact ETH for tokens
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to
    ) external payable returns (uint[] memory amounts) {
        require(path[0] == WETH, "Router: INVALID_PATH");
        amounts = InterfinSwapLibrary.getAmountsOut(factory, msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "Router: INSUFFICIENT_OUTPUT_AMOUNT");
        IWETH(WETH).deposit{value: amounts[0]}();
        require(IWETH(WETH).transfer(InterfinSwapLibrary.pairFor(factory, path[0], path[1]), amounts[0]), "Router: WETH_TRANSFER_FAILED");
        _swap(amounts, path, to);
    }

    // Swap exact tokens for ETH
    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to
    ) external returns (uint[] memory amounts) {
        require(path[path.length - 1] == WETH, "Router: INVALID_PATH");
        amounts = InterfinSwapLibrary.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "Router: INSUFFICIENT_OUTPUT_AMOUNT");
        IERC20(path[0]).transferFrom(msg.sender, InterfinSwapLibrary.pairFor(factory, path[0], path[1]), amounts[0]);
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        payable(to).transfer(amounts[amounts.length - 1]);
    }

    // Internal swap helper
    function _swap(uint[] memory amounts, address[] memory path, address to) internal {
        for (uint i = 0; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            address pair = InterfinSwapLibrary.pairFor(factory, input, output);
            (address token0,) = InterfinSwapLibrary.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint112 amount0Out, uint112 amount1Out) = input == token0
                ? (0, uint112(amountOut))
                : (uint112(amountOut), 0);
            address toAddress = i < path.length - 2
                ? InterfinSwapLibrary.pairFor(factory, output, path[i + 2])
                : to;
            IInterfinSwapPair(pair).swap(amount0Out, amount1Out, toAddress);
        }
    }
}