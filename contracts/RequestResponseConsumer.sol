// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {RequestResponseConsumerFulfillUint128} from "@bisonai/orakl-contracts/src/v0.1/RequestResponseConsumerFulfill.sol";
import {RequestResponseConsumerBase} from "@bisonai/orakl-contracts/src/v0.1/RequestResponseConsumerBase.sol";
import {Orakl} from "@bisonai/orakl-contracts/src/v0.1/libraries/Orakl.sol";
import {IPrepayment} from "@bisonai/orakl-contracts/src/v0.1/interfaces/IPrepayment.sol";

// @notice `RequestResponseConsumer` contract requests BTC/USDT price
// @notice pair from Coinbase API through Orakl Network
// @notice Request-Response service.  In this example code, we request
// @notice `uint128` data type, and use
// @notice `RequestResponseConsumerFulfillUint128` abstract contract
// @notice which allows to fulfill requested price by off-chain Orakl Network
// @notice in `uint128` data type.
// @notice In case, we need to receive other data types, we can create
// @notice a jobID for any of the following data types:
// @notice  * uint128,
// @notice  * int256,
// @notice  * bool,
// @notice  * string,
// @notice  * bytes32,
// @notice  * bytes.
// @notice Then, we also need to inherit a corresponding abstract
// @notice contract:
// @notice  * `RequestResponseConsumerFulfillUint128`,
// @notice  * `RequestResponseConsumerFulfillInt256`,
// @notice  * `RequestResponseConsumerFulfillBool`,
// @notice  * `RequestResponseConsumerFulfillString`,
// @notice  * `RequestResponseConsumerFulfillBytes32`,
// @notice  * `RequestResponseConsumerFulfillBytes`,
// @notice respectively.
contract RequestResponseConsumer is RequestResponseConsumerFulfillUint128 {
    using Orakl for Orakl.Request;
    uint128 public sResponse;
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
    ) public onlyOwner returns (uint256 requestId) {
        bytes32 jobId = keccak256(abi.encodePacked("uint128"));
        uint8 numSubmission = 1;

        Orakl.Request memory req = buildRequest(jobId);
        req.add("get", "https://api.coinbase.com/v2/exchange-rates?currency=BTC");
        req.add("path", "data,rates,USDT");
        req.add("pow10", "8");

        requestId = COORDINATOR.requestData(req, callbackGasLimit, accId, numSubmission);
    }

    function requestDataDirectPayment(
        uint32 callbackGasLimit
    ) public payable onlyOwner returns (uint256 requestId) {
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

    function fulfillDataRequest(uint256 /*requestId*/, uint128 response) internal override {
        sResponse = response;
    }

    function cancelRequest(uint256 requestId) external onlyOwner {
        COORDINATOR.cancelRequest(requestId);
    }

    function withdrawTemporary(uint64 accId) external onlyOwner {
        address prepaymentAddress = COORDINATOR.getPrepaymentAddress();
        IPrepayment(prepaymentAddress).withdrawTemporary(accId, payable(msg.sender));
    }
}
