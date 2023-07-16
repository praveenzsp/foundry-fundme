// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelpConfig} from "./HelpConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelpConfig helpConfig = new HelpConfig();
        vm.startBroadcast();
        FundMe fundMe = new FundMe(helpConfig.activeNetworkConfig());
        vm.stopBroadcast();
        return fundMe;
    }
}
