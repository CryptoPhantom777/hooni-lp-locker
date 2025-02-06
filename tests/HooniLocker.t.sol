// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.28 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import { HooniLocker } from "../src/HooniLocker.sol";
import { HooniPaymentSplitter } from "../src/HooniPaymentSplitter.sol";
import { Deploy } from "../script/Deploy.s.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface IERC721 {
   function transferFrom(address from, address to, uint256 tokenId) external;
}

contract HooniLockerTest is Test {
    function setUp() public virtual {
    }

    function testCollectFees() public {
        vm.createSelectFork("https://unichain.leakedrpc.com");
        vm.startPrank(0x7E035Fb048a31e0481b88074557415b1C187242B);
        HooniLocker locker = new HooniLocker();
        IERC721(address(locker.positionManager())).transferFrom(
            0x7E035Fb048a31e0481b88074557415b1C187242B,
            address(locker),
            locker.tokenId()
        );
        locker.collectFees();
    }

    function testCollectFeesWithPaymentSplitter() public {
        vm.createSelectFork("https://unichain.leakedrpc.com");
        vm.startPrank(0x7E035Fb048a31e0481b88074557415b1C187242B);

        HooniLocker locker = new HooniLocker();

        IERC721(address(locker.positionManager())).transferFrom(
            0x7E035Fb048a31e0481b88074557415b1C187242B,
            address(locker),
            locker.tokenId()
        );

        address[] memory payees = new address[](2);
        uint256[] memory shares = new uint256[](2);

        address feeRecipient1 = address(0xb45D02f3e809141c89434B704C74B3CE1074EeB7);
        address feeRecipient2 = address(0xef22847F137E59a3e5cD638CE717fB9F25c9f15a);

        payees[0] = feeRecipient1;
        payees[1] = feeRecipient2;

        shares[0] = 1;
        shares[1] = 1;

        HooniPaymentSplitter paymentSplitter = new HooniPaymentSplitter(address(locker), payees, shares);

        locker.setFeeRecipient(address(paymentSplitter));
        (uint256 accruedETH, uint256 accruedHOONI) = locker.collectFees();

        IERC20 hooni = IERC20(address(paymentSplitter.hooni()));

        assertEq(address(paymentSplitter).balance, accruedETH, "PaymentSplitter balance should be equal to accrued ETH");
        assertEq(hooni.balanceOf(address(paymentSplitter)), accruedHOONI, "PaymentSplitter Hooni balance should be equal to accrued HOONI");

        paymentSplitter.releaseAll();
        assertApproxEqAbs(address(paymentSplitter).balance, 0, 1, "PaymentSplitter balance should be 0");
        assertApproxEqAbs(feeRecipient1.balance, accruedETH / 2, 1, "Fee recipient 1 balance should be equal to half of accrued ETH");
        assertApproxEqAbs(feeRecipient2.balance, accruedETH / 2, 1, "Fee recipient 2 balance should be equal to half of accrued ETH");
        assertApproxEqAbs(hooni.balanceOf(address(paymentSplitter)), 0, 1, "PaymentSplitter Hooni balance should be 0");
        assertApproxEqAbs(hooni.balanceOf(feeRecipient1), accruedHOONI / 2, 1, "Fee recipient 1 Hooni balance should be equal to half of accrued HOONI");
        assertApproxEqAbs(hooni.balanceOf(feeRecipient2), accruedHOONI / 2, 1, "Fee recipient 2 Hooni balance should be equal to half of accrued HOONI");
    }

    // function testDeployCollectSplit() public {
    //     vm.startPrank(0x7E035Fb048a31e0481b88074557415b1C187242B);
    //     Deploy hooniLockerDeployer = new Deploy();
    //     (HooniLocker locker, HooniPaymentSplitter paymentSplitter) = hooniLockerDeployer.run();
    // }
}
