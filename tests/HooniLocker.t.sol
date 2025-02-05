// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.28 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import { HooniLocker } from "../src/HooniLocker.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface IERC721 {
   function transferFrom(address from, address to, uint256 tokenId) external;
}

contract HooniLockerTest is Test {
    HooniLocker internal locker;

    function setUp() public virtual {
    }

    function testCollectFees() public {
        vm.createSelectFork("https://unichain.leakedrpc.com");
        vm.startPrank(0x7E035Fb048a31e0481b88074557415b1C187242B);
        locker = new HooniLocker();
        IERC721(address(locker.positionManager())).transferFrom(
            0x7E035Fb048a31e0481b88074557415b1C187242B,
            address(locker),
            locker.tokenId()
        );
        locker.collectFees();
    }
}
