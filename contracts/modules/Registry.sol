// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Registry {
    string[] collections;
    address[] nfts;
    mapping(string => address[]) collections_to_NFTs;
    mapping(address => string[]) NFTs_to_collections;

    function getAllCollections() public view returns(string[] memory) {
        return collections;
    }

    function getAllNFTs() public view returns(address[] memory) {
        return nfts;
    }

    function createCreateCollection(string memory _name) public {
        collections.push(_name);
    }

    function addNFTtoMarketplace(string memory _name) public {
        collections.push(_name);
    }

    function addNFTinCollection(address _nft, string calldata _collection) public {
        collections_to_NFTs[_collection].push(_nft);
        NFTs_to_collections[_nft].push(_collection);
    }
}