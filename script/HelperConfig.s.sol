// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/*
TODO: 
1. Deploy mocks when we are on a local anvil chain
TODO:
2. Keep track of contract address across different chains

? Sepolia ETH / USD Address
? https://docs.chain.link/data-feeds/price-feeds/addresses

? Mainnet ETH / USD Address
? https://docs.chain.link/docs/ethereum-addresses/
*/

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // If we're on a local anvil chain, we deploy mocks
    // Otherwise, grab the existing address from the live network
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    NetworkConfig public activeNetworkConfig; // = getSepoliaEthConfig(); or = getAnvilEthConfig(); (whichever is active)

    struct NetworkConfig {
        address priceFeed; // ETH / USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
            // Every network has its own chainId, the one above is for Sepolia
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // return 0x694AA1769357215DE4FAC081bf1f309aDC325306;
        // price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig(
            {
                priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            });

        return sepoliaConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        } // To prevent re-deploying the mocks

        //TODO: 1. Deploy the mocks

        vm.startBroadcast();

        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);

        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
                priceFeed: address(mockV3Aggregator)
            });
        
        //TODO: 2. Return the mock address
        return anvilConfig;
    }
}