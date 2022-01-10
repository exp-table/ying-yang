pragma solidity ^0.8.10;
import "@openzeppelin/contracts/access/Ownable.sol";

/*
    Taken from https://cairo-lang.org/docs/_static/L1L2Example.sol
*/

interface IStarknetCore {
    /**
      Sends a message to an L2 contract.

      Returns the hash of the message.
    */
    function sendMessageToL2(
        uint256 to_address,
        uint256 selector,
        uint256[] calldata payload
    ) external returns (bytes32);

    /**
      Consumes a message that was sent from an L2 contract.

      Returns the hash of the message.
    */
    function consumeMessageFromL2(uint256 fromAddress, uint256[] calldata payload)
        external
        returns (bytes32);
}

contract VendingMachine is Ownable {
    // The StarkNet core contract.
    IStarknetCore starknetCore;

    uint256 public constant PRICE = 1;
    uint256 public l2Address;

    // The selector of the "mint" l1_handler.
    uint256 constant MINT_SELECTOR =
        1329909728320632088402217562277154056711815095720684343816173432540100887380;

    /**
      Initializes the contract state.
    */
    constructor(IStarknetCore starknetCore_) payable {
        starknetCore = starknetCore_;
    }

    function setL2Address(uint256 l2Address_) public onlyOwner {
        l2Address = l2Address_;
    }

    function pay(
        uint256 user
    ) external payable {
        require(msg.value == PRICE);
        // Construct the mint message's payload.
        uint256[] memory payload = new uint256[](1);
        payload[0] = user;

        // Send the message to the StarkNet core contract.
        starknetCore.sendMessageToL2(l2Address, MINT_SELECTOR, payload);
    }
}
