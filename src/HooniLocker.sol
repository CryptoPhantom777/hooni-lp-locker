// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPositionManager} from "@uniswap/v4-periphery/src/interfaces/IPositionManager.sol";
import {Actions} from "@uniswap/v4-periphery/src/libraries/Actions.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract HooniLocker is Ownable {
   IPositionManager public constant positionManager = IPositionManager(0x4529A01c7A0410167c5740C487A8DE60232617bf);
   uint256 public constant tokenId = 4;
   address public feeRecipient;
   mapping(address => bool) public whitelistedCallers;

   event FeesCollected(address recipient, uint256 amount0, uint256 amount1);

   error ZeroRecipient();
   error NotWhitelisted();

   constructor() Ownable(msg.sender) {
       feeRecipient = msg.sender;
   }

   function setFeeRecipient(address _feeRecipient) external onlyOwner {
       if(_feeRecipient == address(0)) revert ZeroRecipient();
       feeRecipient = _feeRecipient;
   }

   function setWhitelistedCaller(address caller, bool whitelisted) external onlyOwner {
       whitelistedCallers[caller] = whitelisted;
   }

   /**
    * @notice Collects fees from the position using a zero-liquidity decrease operation
    * @dev In v4, fees are collected by calling DECREASE_LIQUIDITY with zero liquidity
    * since fees are automatically credited during liquidity operations. We set minimums
    * to 0 since fees cannot be manipulated in a front-run attack, unlike other liquidity
    * operations where slippage protection is crucial.
    *
    * For more info check the docs: https://docs.uniswap.org/contracts/v4/guides/position-manager#collecting-fees
    */
   function collectFees() external returns (uint256 accruedToken0, uint256 accruedToken1) {
       if(!whitelistedCallers[msg.sender] && msg.sender != owner()) revert NotWhitelisted();
       if (feeRecipient == address(0)) revert ZeroRecipient();

       bytes memory actions = abi.encodePacked(
           uint8(Actions.DECREASE_LIQUIDITY),
           uint8(Actions.TAKE_PAIR)
       );

       bytes[] memory params = new bytes[](2);

       // Parameters for DECREASE_LIQUIDITY:
       // - tokenId: position identifier
       // - liquidity: 0 (to collect fees without removing position liquidity)
       // - amount0Min: 0 (no min needed for fee collection)
       // - amount1Min: 0 (no min needed for fee collection)
       // - hookData: "" (no hook data needed)
       params[0] = abi.encode(tokenId, 0, 0, 0, "");

       (PoolKey memory poolKey,) = positionManager.getPoolAndPositionInfo(tokenId);
       params[1] = abi.encode(poolKey.currency0, poolKey.currency1, feeRecipient);

       uint256 amount0Before = poolKey.currency0.balanceOf(feeRecipient);
       uint256 amount1Before = poolKey.currency1.balanceOf(feeRecipient);

       positionManager.modifyLiquidities(
           abi.encode(actions, params),
           block.timestamp + 60
       );

       accruedToken0 = poolKey.currency0.balanceOf(feeRecipient) - amount0Before;
       accruedToken1 = poolKey.currency1.balanceOf(feeRecipient) - amount1Before;

       emit FeesCollected(feeRecipient, accruedToken0, accruedToken1);
   }
}
