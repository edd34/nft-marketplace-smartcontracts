// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Collections {
    uint8 private collectionIds;

    struct Collection {
        uint8 id; //256 Collection maximum
        string name;
        string image;
        uint[] NFT; // NFT per collection
    }

    mapping(uint => Collection) collectionMapping;

    function createCollection(string memory name, string memory image) public {
        uint[] memory NFTs;
        collectionMapping[collectionIds] = Collection(collectionIds, name, image, NFTs);
        collectionIds++;
    }

}