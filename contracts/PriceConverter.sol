pragma solidity ^0.8.17;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint) {
        // ETH / USD rate in 8 decimals - obtained from https://docs.chain.link/data-feeds/price-feeds/
        (, int answer, , , ) = priceFeed.latestRoundData();
        return uint(answer * 10000000000);
    }

    function getConvertionRate(
        uint ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint) {
        uint price = getPrice(priceFeed);
        uint ethAmountUsd = (ethAmount * price) / 1 ether;
        return ethAmountUsd;
    }
}
