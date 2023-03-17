// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@bisonai/orakl-contracts/src/v0.1/RequestResponseConsumerBase.sol";
import "@bisonai/orakl-contracts/src/v0.1/interfaces/RequestResponseCoordinatorInterface.sol";

contract RequestResponseConsumer is RequestResponseConsumerBase {
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
        bytes32 jobId = keccak256(abi.encodePacked("any-api-int256"));

        Orakl.Request memory req = buildRequest(jobId);
        req.add("get", "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=ETH&tsyms=USD");
        req.add("path", "RAW,ETH,USD,PRICE");

        requestId = COORDINATOR.requestData(
            req,
            callbackGasLimit,
            accId
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
        bytes32 jobId = keccak256(abi.encodePacked("any-api-int256"));

        Orakl.Request memory req = buildRequest(jobId);
        req.add("get", "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=ETH&tsyms=USD");
        req.add("path", "RAW,ETH,USD,PRICE");

        requestId = COORDINATOR.requestData{value: msg.value}(
            req,
            callbackGasLimit
        );
    }

    function fulfillDataRequest(
        uint256 /*requestId*/,
        uint256 response
    )
        internal
        override
    {
        sResponse = response;
    }
}
