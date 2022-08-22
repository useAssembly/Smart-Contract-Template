pragma solidity ^0.6.2;

import "https://raw.githubusercontent.com/smartcontractkit/chainlink/develop/contracts/src/v0.6/VRFConsumerBase.sol";
import "./Raffle.sol";

contract RandomNumberGenerator is VRFConsumerBase {
    address requester;
    bytes32 keyHash;
    uint256 fee;

    constructor(
        address _vrfCoordinator,
        address _link,
        bytes32 _keyHash,
        uint256 _fee
    ) public VRFConsumerBase(_vrfCoordinator, _link) {
        keyHash = _keyHash;
        fee = _fee;
    }

    function fulfillRandomness(bytes32 _requestId, uint256 _randomness)
        external
        override
    {
        Raffle(requester).numberDrawn(_requestId, _randomness);
    }

    function request(uint256 _seed) public returns (bytes32 requestId) {
        require(keyHash != bytes32(0), "Must have valid key hash");
        requester = msg.sender;
        return this.requestRandomness(keyHash, fee, _seed);
    }
}
