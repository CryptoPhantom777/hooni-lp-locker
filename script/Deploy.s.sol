// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.28 <0.9.0;

import { HooniLocker } from "../src/HooniLocker.sol";
import { HooniPaymentSplitter } from "../src/HooniPaymentSplitter.sol";

import { BaseScript } from "./Base.s.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface IERC721 {
   function transferFrom(address from, address to, uint256 tokenId) external;
}

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract Deploy is BaseScript {
    function run() public broadcast returns (HooniLocker locker, HooniPaymentSplitter paymentSplitter) {
        locker = new HooniLocker();

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

        paymentSplitter = new HooniPaymentSplitter(address(locker), payees, shares);

        locker.setFeeRecipient(address(paymentSplitter));
        locker.setWhitelistedCaller(feeRecipient1, true);
        locker.setWhitelistedCaller(feeRecipient2, true);
        (uint256 accruedETH, uint256 accruedHOONI) = locker.collectFees();

        IERC20 hooni = IERC20(address(paymentSplitter.hooni()));

        require(hooni.balanceOf(address(paymentSplitter)) == accruedHOONI, "PaymentSplitter Hooni balance should be equal to accrued HOONI");
        require(address(paymentSplitter).balance == accruedETH, "PaymentSplitter balance should be equal to accrued ETH");

        paymentSplitter.releaseAll();
        require(address(paymentSplitter).balance <= 1, "PaymentSplitter balance should be 0");
        require(hooni.balanceOf(address(paymentSplitter)) <= 1, "PaymentSplitter Hooni balance should be 0");
        require(hooni.balanceOf(feeRecipient1) == accruedHOONI / 2, "Fee recipient 1 Hooni balance should be equal to half of accrued HOONI");
        require(hooni.balanceOf(feeRecipient2) == accruedHOONI / 2, "Fee recipient 2 Hooni balance should be equal to half of accrued HOONI");
        require(feeRecipient1.balance == accruedETH / 2, "Fee recipient 1 balance should be equal to half of accrued ETH");
        require(feeRecipient2.balance == accruedETH / 2, "Fee recipient 2 balance should be equal to half of accrued ETH");
    }
}
