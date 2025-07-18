// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {CircleLayer} from "../src/CircleLayer.sol";

contract DeployCircleLayerToken is Script {
    function run() external returns (CircleLayer) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        CircleLayer token = new CircleLayer();
        
        vm.stopBroadcast();
        
        console.log("CircleLayer deployed to:", address(token));
        console.log("LP Pair address:", token.pair());
        console.log("Treasury1:", token.treasury1());
        console.log("Treasury2:", token.treasury2());
        
        return token;
    }
}
