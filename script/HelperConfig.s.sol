// SPDX-License-Identifier: MIT


// 1. Deploy Mocks when we are on a local anvil chain
// 2. keep track of contract address accross different chains
// Sepolia ETH / USD Address
// mainnet ETH / USD Address

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig  is Script{
    // If we are on a local Anvil, we deploy mocks
    // otherwise grab the existing address from the live network
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed;  // ETH/USD price feed address
    }

    constructor(){
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig () public pure returns (NetworkConfig memory) {
        // price feed addres
        NetworkConfig memory sepoliaConfig = NetworkConfig({ 
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }
     function getMainnetEthConfig () public pure returns (NetworkConfig memory) {
        // price feed addres
        NetworkConfig memory ethConfig = NetworkConfig({ 
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return ethConfig;
    }

    function getAnvilEthConfig () public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        // price feed address

        //1. deploy the mocks
        //2. return the address of the mocks

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();


        NetworkConfig memory anvilConfig = NetworkConfig({ 
            priceFeed: address(mockPriceFeed)});    
        return anvilConfig;
    }
}