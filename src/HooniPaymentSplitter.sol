// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.26;

import "./PaymentSplitter.sol";

interface IHooniLocker {
    function collectFees() external returns (uint256 accruedToken0, uint256 accruedToken1);
}

contract HooniPaymentSplitter is PaymentSplitter {
    IERC20 public hooni = IERC20(0xeC4a56061d86955D0Df883efb2E5791d99Ea71f2);
    IHooniLocker _locker;
    uint256 _payeesCount;

    constructor(address locker_, address[] memory payees_, uint256[] memory shares_) PaymentSplitter(payees_, shares_) {
        _locker = IHooniLocker(locker_);
        _payeesCount = payees_.length;
    }

    function releaseAll() public {
        for (uint256 i = 0; i < _payeesCount; i++) {
            address payee = super.payee(i);
            super.release(payable(payee));
            super.release(hooni, payee);
        }
    }
}
