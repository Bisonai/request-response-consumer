// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { RequestResponseConsumerFulfillUint128 } from "@bisonai/orakl-contracts/src/v0.1/RequestResponseConsumerFulfill.sol";
import { RequestResponseConsumerBase } from "@bisonai/orakl-contracts/src/v0.1/RequestResponseConsumerBase.sol";
import { Orakl } from "@bisonai/orakl-contracts/src/v0.1/libraries/Orakl.sol";

contract RequestResponseConsumer is RequestResponseConsumerFulfillUint128 {
    using Orakl for Orakl.Request;
    uint256 public sResponse;
    address private sOwner;

    error OnlyOwner(address notOwner);

    modifier onlyOwner() {
        if (msg.sender != sOwner) {
            revert OnlyOwner(msg.sender);
        }
        _;
    }

    constructor(address coordinator) RequestResponseConsumerBase(coordinator) {
        sOwner = msg.sender;
    }

    // Receive remaining payment from requestDataPayment
    receive() external payable {}

    function requestData(
      uint64 accId,
      uint32 callbackGasLimit
    )
        public
        onlyOwner
        returns (uint256 requestId)
    {
        bytes32 jobId = keccak256(abi.encodePacked("uint128"));
        uint8 numSubmission = 1;

        Orakl.Request memory req = buildRequest(jobId);
        req.add("get", "https://api.coinbase.com/v2/exchange-rates?currency=BTC");
        req.add("path", "data,rates,USDT");
        req.add("pow10", "8");

        requestId = COORDINATOR.requestData(
            req,
            callbackGasLimit,
            accId,
            numSubmission
        );
    }

    function requestDataDirectPayment(
      uint32 callbackGasLimit
    )
        public
        payable
        onlyOwner
        returns (uint256 requestId)
    {
        bytes32 jobId = keccak256(abi.encodePacked("uint128"));
        uint8 numSubmission = 1;

        Orakl.Request memory req = buildRequest(jobId);
        req.add("get", "https://api.coinbase.com/v2/exchange-rates?currency=BTC");
        req.add("path", "data,rates,USDT");
        req.add("pow10", "8");

        requestId = COORDINATOR.requestData{value: msg.value}(
            req,
            callbackGasLimit,
            numSubmission,
            address(this)
        );
    }

    function fulfillDataRequest(
        uint256 /*requestId*/,
        uint128 response
    )
        internal
        override
    {
        sResponse = response;
    }
}
