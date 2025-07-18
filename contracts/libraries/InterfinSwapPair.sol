// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract InterfinSwapPair {
    address public token0;
    address public token1;

    uint112 public reserve0;
    uint112 public reserve1;

    event Initialized(address indexed token0, address indexed token1);
    event LiquidityAdded(address indexed provider, uint112 amount0, uint112 amount1);
    event LiquidityRemoved(address indexed provider, uint112 amount0, uint112 amount1);
    event Swapped(address indexed trader, uint112 amountIn, uint112 amountOut, address inputToken, address outputToken);

    bool public initialized;

    function initialize(address _token0, address _token1) external {
        require(!initialized, "InterfinSwapPair: ALREADY_INITIALIZED");
        token0 = _token0;
        token1 = _token1;
        initialized = true;
        emit Initialized(_token0, _token1);
        _updateReserves();
    }

    function getReserves() external view returns (uint112, uint112) {
        return (reserve0, reserve1);
    }

    function addLiquidity(uint112 amount0, uint112 amount1) external {
        require(initialized, "InterfinSwapPair: NOT_INITIALIZED");
        require(amount0 > 0 && amount1 > 0, "InterfinSwapPair: INVALID_AMOUNTS");

        require(IERC20(token0).transferFrom(msg.sender, address(this), amount0), "InterfinSwapPair: TRANSFER_FAILED_TOKEN0");
        require(IERC20(token1).transferFrom(msg.sender, address(this), amount1), "InterfinSwapPair: TRANSFER_FAILED_TOKEN1");

        _updateReserves();

        emit LiquidityAdded(msg.sender, amount0, amount1);
    }

    function removeLiquidity(uint112 amount0, uint112 amount1) external {
        require(initialized, "InterfinSwapPair: NOT_INITIALIZED");
        require(amount0 <= reserve0 && amount1 <= reserve1, "InterfinSwapPair: INSUFFICIENT_RESERVE");

        require(IERC20(token0).transfer(msg.sender, amount0), "InterfinSwapPair: TRANSFER_FAILED_TOKEN0");
        require(IERC20(token1).transfer(msg.sender, amount1), "InterfinSwapPair: TRANSFER_FAILED_TOKEN1");

        _updateReserves();

        emit LiquidityRemoved(msg.sender, amount0, amount1);
    }

    function swap(address inputToken, uint112 amountIn) external {
        require(initialized, "InterfinSwapPair: NOT_INITIALIZED");
        require(inputToken == token0 || inputToken == token1, "InterfinSwapPair: INVALID_TOKEN");

        address outputToken = inputToken == token0 ? token1 : token0;

        require(IERC20(inputToken).transferFrom(msg.sender, address(this), amountIn), "InterfinSwapPair: TRANSFER_FAILED_INPUT");

        _updateReserves();

        uint112 inputReserve = inputToken == token0 ? reserve0 : reserve1;
        uint112 outputReserve = inputToken == token0 ? reserve1 : reserve0;

        uint112 amountOut = uint112((uint256(amountIn) * uint256(outputReserve)) / (uint256(inputReserve) + uint256(amountIn)));
        require(amountOut > 0 && amountOut <= outputReserve, "InterfinSwapPair: INSUFFICIENT_OUTPUT_AMOUNT");

        require(IERC20(outputToken).transfer(msg.sender, amountOut), "InterfinSwapPair: TRANSFER_FAILED_OUTPUT");

        _updateReserves();

        emit Swapped(msg.sender, amountIn, amountOut, inputToken, outputToken);
    }

    function _updateReserves() internal {
        reserve0 = uint112(IERC20(token0).balanceOf(address(this)));
        reserve1 = uint112(IERC20(token1).balanceOf(address(this)));
    }
}