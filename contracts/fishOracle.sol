// SPDX-License-Identifier: AGPL-3.0-only
// Using the same Copyleft License as in the original Repository
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;
import "./libraries/IOracle.sol";
import "@sushiswap/core/contracts/uniswapv2/interfaces/IUniswapV2Factory.sol";
import "@sushiswap/core/contracts/uniswapv2/interfaces/IUniswapV2Pair.sol";
import "./libraries/FixedPoint.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./libraries/BoringMath.sol";

// solhint-disable not-rely-on-time

// adapted from https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/examples/ExampleSlidingWindowOracle.sol
interface IAggregator {
    function latestAnswer() external view returns (int256 answer);
}

contract FishOracle is Initializable {
    using FixedPoint for *;
    using BoringMath for uint256;
    uint256 public constant PERIOD = 1 minutes;
    // IAggregator public constant AVAX_USD = IAggregator(0x0A77230d17318075983913bC2145DB16C7366156);
    IUniswapV2Pair public FISH_USDC;
    address public FISH;

    function initialize(
        IUniswapV2Pair _FISH_USDC,
        address _FISH
    ) external initializer {
        FISH_USDC = _FISH_USDC;
        FISH = _FISH;
    }

    struct PairInfo {
        uint256 priceCumulativeLast;
        uint32 blockTimestampLast;
        uint144 priceAverage;
    }
    PairInfo public pairInfo;

    function _get(uint32 blockTimestamp) public view returns (uint256) {
        (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        ) = FISH_USDC.getReserves();
        uint256 priceCumulative = address(FISH) == FISH_USDC.token0()
            ? FISH_USDC.price0CumulativeLast()
            : FISH_USDC.price1CumulativeLast();
        (reserve0, reserve1) = address(FISH) == FISH_USDC.token0()
            ? (reserve1, reserve0)
            : (reserve0, reserve1);
        priceCumulative +=
            uint256(FixedPoint.fraction(reserve0, reserve1)._x) *
            (blockTimestamp - blockTimestampLast);
        return priceCumulative;
    }

    // Get the latest exchange rate, if no valid (recent) rate is available, return false
    function get(bytes calldata data) external returns (bool, uint256) {
        uint32 blockTimestamp = uint32(block.timestamp);
        if (pairInfo.blockTimestampLast == 0) {
            pairInfo.blockTimestampLast = blockTimestamp;
            pairInfo.priceCumulativeLast = _get(blockTimestamp);
            return (false, 0);
        }
        uint32 timeElapsed = blockTimestamp - pairInfo.blockTimestampLast; // overflow is desired
        if (timeElapsed < PERIOD) {
            return (true, pairInfo.priceAverage);
        }
        uint256 priceCumulative = _get(blockTimestamp);
        pairInfo.priceAverage = uint144(
            1e54 /
                (
                    uint256(1e18).mul(
                        uint256(
                            FixedPoint
                                .uq112x112(
                                    uint224(
                                        (priceCumulative -
                                            pairInfo.priceCumulativeLast) /
                                            timeElapsed
                                    )
                                )
                                .mul(1e18)
                                .decode144()
                        )
                    ) /*.mul(uint256(AVAX_USD.latestAnswer())) / 1e9*/
                )
        );
        pairInfo.blockTimestampLast = blockTimestamp;
        pairInfo.priceCumulativeLast = priceCumulative;
        return (true, pairInfo.priceAverage);
    }

    // Check the last exchange rate without any state changes
    //均价
    //预防闪电贷攻击
    function peek(bytes calldata data) public view returns (bool, uint256) {
        uint32 blockTimestamp = uint32(block.timestamp);
        if (pairInfo.blockTimestampLast == 0) {
            return (false, 0);
        }
        uint32 timeElapsed = blockTimestamp - pairInfo.blockTimestampLast; // overflow is desired
        if (timeElapsed < PERIOD) {
            return (true, pairInfo.priceAverage);
        }
        uint256 priceCumulative = _get(blockTimestamp);
        uint144 priceAverage = uint144(
            1e54 /
                (
                    uint256(1e18).mul(
                        uint256(
                            FixedPoint
                                .uq112x112(
                                    uint224(
                                        (priceCumulative -
                                            pairInfo.priceCumulativeLast) /
                                            timeElapsed
                                    )
                                )
                                .mul(1e18)
                                .decode144()
                        )
                    ) /*.mul(uint256(AVAX_USD.latestAnswer())) / 1e9*/
                )
        );
        return (true, priceAverage);
    }

    // Check the current spot exchange rate without any state changes
    //当前LP价格
    function peekSpot(
        bytes calldata data
    ) external view returns (uint256 rate) {
        (uint256 reserve0, uint256 reserve1, ) = FISH_USDC.getReserves();

        (reserve0, reserve1) = address(FISH) == FISH_USDC.token0()
            ? (reserve1, reserve0)
            : (reserve0, reserve1);
        rate = 1e54 / (uint256(1e18).mul(reserve0.mul(1e18) / reserve1));
    }

    function name(bytes calldata) public pure returns (string memory) {
        return "FISH_USDC Oracle";
    }

    function symbol(bytes calldata) public pure returns (string memory) {
        return "FISH";
    }
}
