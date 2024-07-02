// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BeatMarketplace {
    struct Beat {
        uint id;
        address payable creator;
        string title;
        string ipfsHash;
        uint price;
        bool isSold;
    }

    uint public nextBeatId;
    mapping(uint => Beat) public beats;

    event BeatPosted(uint id, address creator, string title, string ipfsHash, uint price);
    event BeatPurchased(uint id, address buyer, uint price);

    function postBeat(string memory _title, string memory _ipfsHash, uint _price) external {
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(bytes(_ipfsHash).length > 0, "IPFS hash cannot be empty");
        require(_price > 0, "Price must be greater than zero");

        beats[nextBeatId] = Beat({
            id: nextBeatId,
            creator: payable(msg.sender),
            title: _title,
            ipfsHash: _ipfsHash,
            price: _price,
            isSold: false
        });
        emit BeatPosted(nextBeatId, msg.sender, _title, _ipfsHash, _price);
        nextBeatId++;
    }

    function buyBeat(uint _id) external payable {
        require(_id < nextBeatId, "Beat does not exist");
        Beat storage beat = beats[_id];
        require(msg.value >= beat.price, "Insufficient funds");
        require(!beat.isSold, "Beat already sold");
        
        // Using assert to check internal error or invariants
        assert(beat.price == msg.value);

        beat.isSold = true;
        beat.creator.transfer(msg.value);

        emit BeatPurchased(_id, msg.sender, msg.value);
    }

    function getBeat(uint _id) external view returns (Beat memory) {
        require(_id < nextBeatId, "Beat does not exist");
        return beats[_id];
    }

    // Function to demonstrate revert usage
    function removeBeat(uint _id) external {
        require(_id < nextBeatId, "Beat does not exist");
        Beat storage beat = beats[_id];
        require(msg.sender == beat.creator, "Only creator can remove the beat");

        if (beat.isSold) {
            revert("Cannot remove a sold beat");
        }

        delete beats[_id];
    }
}