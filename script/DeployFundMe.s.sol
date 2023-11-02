// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external payable returns(FundMe) {
        //* Anything before vm.startBroadcast is not a "real" transaction, and doesn't cost any gas
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
        // Usually, this returns a tuple of all struct fields, but since there's only 1 field in this struct, no need to wrap the address in parenthesis

        vm.startBroadcast();
        //! Anything AFTER vm.startBroadcast is a "REAL" transaction, and COSTS GAS to execute
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        // Address found on : https://docs.chain.link/data-feeds/api-reference (Google: `chainlink aggregatorv3interface address`)
        vm.stopBroadcast();
        return fundMe;
    }
}