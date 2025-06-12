// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract CasinoRoulette is VRFConsumerBaseV2, ReentrancyGuard {
    enum BetType { Color, Number }

    struct Bet {
        address user;
        uint amount;
        BetType betType;
        int choice;
        bool resolved;
    }

    uint public constant NUM_POCKETS = 38;
    uint public counter = 0;
    mapping(uint => Bet) public bets;

    // Payout multipliers
    uint public colorPayoutMultiplier = 2; // 2x
    uint public numberPayoutMultiplier = 35; // 35x

    // House edge in basis points (e.g., 500 = 5%)
    uint public houseEdgeBasisPoints = 200; // 2%

    VRFCoordinatorV2Interface public immutable COORDINATOR;
    bytes32 public s_keyHash;
    uint64 public s_subscriptionId;

    uint public requestConfirmations = 3;

    // RED and BLACK mappings
    mapping(int => int) public COLORS;

    // Events
    event BetPlaced(address indexed user, uint indexed id, BetType betType, int choice, uint amount);
    event SpinRequested(uint indexed id, uint requestId);
    event SpinResult(uint indexed id, int landed);

    address public owner;

    constructor(
        address vrfCoordinator,
        bytes32 keyHash,
        uint64 subscriptionId
    ) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_keyHash = keyHash;
        s_subscriptionId = subscriptionId;

        owner = msg.sender;

        // Initialize red pockets
        uint8[18] memory redNumbers = [1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36];
        for (uint i = 0; i < redNumbers.length; i++) {
            COLORS[int(redNumbers[i])] = 1;
        }
    }

    function wager(BetType betType, int choice) external payable nonReentrant {
        require(msg.value > 0, "Must send ETH");

        if (betType == BetType.Color) {
            require(choice == 0 || choice == 1, "Invalid color");
        } else {
            require(choice >= -1 && choice <= 36, "Invalid number");
        }

        counter++;
        bets[counter] = Bet({
            user: msg.sender,
            amount: msg.value,
            betType: betType,
            choice: choice,
            resolved: false
        });

        emit BetPlaced(msg.sender, counter, betType, choice, msg.value);
    }

    function spin(uint id) external nonReentrant {
        Bet storage bet = bets[id];
        require(bet.user == msg.sender, "Only bet owner can resolve");
        require(!bet.resolved, "Already resolved");

        uint requestId = COORDINATOR.requestRandomWords(
            s_keyHash,
            s_subscriptionId,
            requestConfirmations,
            100000, // callbackGasLimit
            1       // numWords
        );

        emit SpinRequested(id, requestId);
    }

    function fulfillRandomWords(uint requestId, uint[] memory randomWords) internal override {
        uint id = requestId; // For simplicity, map directly
        Bet storage bet = bets[id];

        require(!bet.resolved, "Already resolved");

        int landed = int(randomWords[0] % NUM_POCKETS) - 1;

        if (bet.betType == BetType.Color) {
            if (landed > 0 && COLORS[landed] == bet.choice) {
                uint payout = calculatePayout(bet.amount, colorPayoutMultiplier);
                (bool success,) = bet.user.call{value: payout}("");
                require(success, "Transfer failed");
            }
        } else if (bet.betType == BetType.Number) {
            if (landed == bet.choice) {
                uint payout = calculatePayout(bet.amount, numberPayoutMultiplier);
                (bool success,) = bet.user.call{value: payout}("");
                require(success, "Transfer failed");
            }
        }

        bet.resolved = true;
        emit SpinResult(id, landed);
    }

    function calculatePayout(uint amount, uint multiplier) private view returns (uint) {
        uint total = amount * multiplier;
        uint houseCut = (total * houseEdgeBasisPoints) / 10000;
        return total - houseCut;
    }

    function fund() external payable {}

    function kill() external {
        require(msg.sender == owner, "Only owner");
        selfdestruct(payable(owner));
    }

    receive() external payable {}
}