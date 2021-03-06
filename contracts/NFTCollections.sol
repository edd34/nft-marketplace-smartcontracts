// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTCollections {
    using Counters for Counters.Counter;
    Counters.Counter private _collectionIds;

    struct NFTCollection {
        uint256 id;
        string name;
        string image;
        uint256[] NFT; // NFT per collection
    }

    mapping(uint256 => NFTCollection) NFTCollectionMapping;
    mapping(uint256 => uint256) NFTinCollectionMapping;

    function getCollectionCount() public view returns (uint256) {
        return _collectionIds.current();
    }

    function getCollectionInfo(uint256 _coll_id)
        public
        view
        returns (NFTCollection memory)
    {
        return NFTCollectionMapping[_coll_id];
    }

    function getCollectionOfNFT(uint256 NFT_id) public view returns (uint256) {
        return NFTinCollectionMapping[NFT_id];
    }

    function _createCollection(string memory name, string memory image)
        internal
    {
        uint256[] memory NFTs;
        uint256 _collectionId = _collectionIds.current();
        NFTCollectionMapping[_collectionId] = NFTCollection(
            _collectionId,
            name,
            image,
            NFTs
        );
        _collectionIds.increment();
    }

    function _addNFTtoCollection(uint256 _tokenId, uint256 _collectionId)
        internal
    {
        NFTCollection storage myNFTCollection =
            NFTCollectionMapping[_collectionId];
        myNFTCollection.NFT.push(_tokenId);
    }

    // function _removeNFTfromCollection(uint256 _tokenId, uint256 _collectionId) internal {
    //     NFTCollection storage myNFTCollection =
    //         NFTCollectionMapping[_collectionId];
    //     for(uint i = 0; i<myNFTCollection.NFT.length; i++) {
    //         if(myNFTCollection.NFT[i] == _tokenId) {
    //             myNFTCollection.NFT.
    //         }
    //     }
    // }
}
