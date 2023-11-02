// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";

contract DeployFundMe is Script {
    function run() external payable {
        vm.startBroadcast();
        new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // Address found on : https://docs.chain.link/data-feeds/api-reference (Google: `chainlink aggregatorv3interface address`)
        vm.stopBroadcast();
    }
}