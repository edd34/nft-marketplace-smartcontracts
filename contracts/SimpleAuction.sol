// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./NFT.sol";

/**
 * title Auction Repository
 * This contracts allows auctions to be created for non-fungible tokens
 * Moreover, it includes the basic functionalities of an auction house
 */
contract SimpleAuction is NFT {
    // Array with all auctions
    Auction[] public auctions;

    // Mapping from auction index to user bids
    mapping(uint256 => Bid[]) public auctionBids;

    // Mapping from owner to a list of owned auctions
    mapping(address => uint256[]) public auctionOwner;

    // Bid struct to hold bidder and amount
    struct Bid {
        address payable from;
        uint256 amount;
    }

    // Auction struct which holds all the required info
    struct Auction {
        string name;
        uint256 blockDeadline;
        uint256 startPrice;
        string metadata;
        uint256 tokenId;
        address payable owner;
        bool active;
        bool finalized;
    }

    /**
     * dev Guarantees msg.sender is owner of the given auction
     * param _auctionId uint ID of the auction to validate its ownership belongs to msg.sender
     */
    modifier isOwnerAuction(uint256 _auctionId) {
        require(auctions[_auctionId].owner == msg.sender);
        _;
    }

    modifier isOwnerNFT(uint256 _tokenId) {
        require(ownerOf(_tokenId) == msg.sender);
        _;
    }

    constructor(string memory _name, string memory _symbol)
        NFT(_name, _symbol)
    {}

    /**
     * dev Gets the length of auctions
     * return uint representing the auction count
     */
    function getCount() public view returns (uint256) {
        return auctions.length;
    }

    /**
     * dev Gets the bid counts of a given auction
     * param _auctionId uint ID of the auction
     */
    function getBidsCount(uint256 _auctionId) public view returns (uint256) {
        return auctionBids[_auctionId].length;
    }

    /**
     * dev Gets an array of owned auctions
     * param _owner address of the auction owner
     */
    function getAuctionsOf(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory ownedAuctions = auctionOwner[_owner];
        return ownedAuctions;
    }

    /**
     * dev Gets an array of owned auctions
     * param _auctionId uint of the auction owner
     * return amount uint256, address of last bidder
     */
    function getCurrentBid(uint256 _auctionId)
        public
        view
        returns (uint256, address)
    {
        uint256 bidsLength = auctionBids[_auctionId].length;
        // if there are bids refund the last bid
        if (bidsLength > 0) {
            Bid memory lastBid = auctionBids[_auctionId][bidsLength - 1];
            return (lastBid.amount, lastBid.from);
        }
        return (uint256(0), address(0));
    }

    /**
     * dev Gets the total number of auctions owned by an address
     * param _owner address of the owner
     * return uint total number of auctions
     */
    function getAuctionsCountOfOwner(address _owner)
        public
        view
        returns (uint256)
    {
        return auctionOwner[_owner].length;
    }

    /**
     * dev Gets the info of a given auction which are stored within a struct
     * param _auctionId uint ID of the auction
     * return string name of the auction
     * return uint256 timestamp of the auction in which it expires
     * return uint256 starting price of the auction
     * return string representing the metadata of the auction
     * return uint256 ID of the deed registered in DeedRepository
     * return address Address of the DeedRepository
     * return address owner of the auction
     * return bool whether the auction is active
     * return bool whether the auction is finalized
     */
    function getAuctionById(uint256 _auctionId)
        public
        view
        returns (
            string memory name,
            uint256 blockDeadline,
            uint256 startPrice,
            string memory metadata,
            uint256 tokenId,
            address owner,
            bool active,
            bool finalized
        )
    {
        Auction memory auc = auctions[_auctionId];
        return (
            auc.name,
            auc.blockDeadline,
            auc.startPrice,
            auc.metadata,
            auc.tokenId,
            auc.owner,
            auc.active,
            auc.finalized
        );
    }

    /**
     * dev Creates an auction with the given informatin
     * param _deedRepositoryAddress address of the DeedRepository contract
     * param _tokenId uint256 of the deed registered in DeedRepository
     * param _auctionTitle string containing auction title
     * param _metadata string containing auction metadata
     * param _startPrice uint256 starting price of the auction
     * param _blockDeadline uint is the timestamp in which the auction expires
     * return bool whether the auction is created
     */
    function createAuction(
        uint256 _tokenId,
        string memory _auctionTitle,
        string memory _metadata,
        uint256 _startPrice,
        uint256 _blockDeadline
    ) public isOwnerNFT(_tokenId) returns (bool) {
        uint256 auctionId = auctions.length;
        Auction memory newAuction;
        newAuction.name = _auctionTitle;
        newAuction.blockDeadline = _blockDeadline;
        newAuction.startPrice = _startPrice;
        newAuction.metadata = _metadata;
        newAuction.tokenId = _tokenId;
        newAuction.owner = payable(msg.sender);
        newAuction.active = true;
        newAuction.finalized = false;

        auctions.push(newAuction);
        auctionOwner[msg.sender].push(auctionId);

        emit AuctionCreated(msg.sender, auctionId);
        return true;
    }

    function approveAndTransfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal returns (bool) {
        safeTransferFrom(_from, _to, _tokenId);
        return true;
    }

    /**
     * dev Cancels an ongoing auction by the owner
     * dev Deed is transfered back to the auction owner
     * dev Bidder is refunded with the initial amount
     * param _auctionId uint ID of the created auction
     */
    function cancelAuction(uint256 _auctionId)
        public
        isOwnerAuction(_auctionId)
    {
        Auction memory myAuction = auctions[_auctionId];
        uint256 bidsLength = auctionBids[_auctionId].length;

        // if there are bids refund the last bid
        if (bidsLength > 0) {
            Bid memory lastBid = auctionBids[_auctionId][bidsLength - 1];
            payable(lastBid.from).transfer(lastBid.amount);
        }

        // approve and transfer from this contract to auction owner
        myAuction.active = false;
        emit AuctionCanceled(msg.sender, _auctionId);
    }

    /**
     * dev Finalized an ended auction
     * dev The auction should be ended, and there should be at least one bid
     * dev On success Deed is transfered to bidder and auction owner gets the amount
     * param _auctionId uint ID of the created auction
     */
    function finalizeAuction(uint256 _auctionId) public {
        Auction memory myAuction = auctions[_auctionId];
        uint256 bidsLength = auctionBids[_auctionId].length;

        // 1. if auction not ended just revert
        require(block.timestamp > myAuction.blockDeadline, "Auction not ended");

        // if there are no bids cancel
        if (bidsLength == 0) {
            cancelAuction(_auctionId);
        } else {
            // 2. the money goes to the auction owner
            Bid memory lastBid = auctionBids[_auctionId][bidsLength - 1];
            payable(myAuction.owner).transfer(lastBid.amount);

            // approve and transfer from this contract to the bid winner
            if (
                approveAndTransfer(
                    myAuction.owner,
                    lastBid.from,
                    myAuction.tokenId
                )
            ) {
                // TODO update this line
                auctions[_auctionId].active = false;
                auctions[_auctionId].finalized = true;
                emit AuctionFinalized(msg.sender, _auctionId);
            }
        }
    }

    /**
     * dev Bidder sends bid on an auction
     * dev Auction should be active and not ended
     * dev Refund previous bidder if a new bid is valid and placed.
     * param _auctionId uint ID of the created auction
     */
    function bidOnAuction(uint256 _auctionId) external payable {
        uint256 ethAmountSent = msg.value;

        Auction memory myAuction = auctions[_auctionId];
        // owner can't bid on their auctions
        require(myAuction.owner != msg.sender, "Owner can't bid his auction");

        // if auction is expired
        require(block.timestamp < myAuction.blockDeadline, "Auction expired");

        uint256 bidsLength = auctionBids[_auctionId].length;
        uint256 tempAmount = myAuction.startPrice;
        Bid memory lastBid;

        // there are previous bids
        if (bidsLength > 0) {
            lastBid = auctionBids[_auctionId][bidsLength - 1];
            tempAmount = lastBid.amount;
        }

        // check if amount is greater than previous amount
        require(ethAmountSent > tempAmount, "Must bid higher");

        // refund the last bidder
        if (bidsLength > 0) {
            payable(lastBid.from).transfer(lastBid.amount);
        }

        // insert bid
        Bid memory newBid;
        newBid.from = payable(msg.sender);
        newBid.amount = ethAmountSent;
        auctionBids[_auctionId].push(newBid);
        emit BidSuccess(msg.sender, _auctionId);
    }

    event BidSuccess(address _from, uint256 _auctionId);

    // AuctionCreated is fired when an auction is created
    event AuctionCreated(address _owner, uint256 _auctionId);

    // AuctionCanceled is fired when an auction is canceled
    event AuctionCanceled(address _owner, uint256 _auctionId);

    // AuctionFinalized is fired when an auction is finalized
    event AuctionFinalized(address _owner, uint256 _auctionId);
}
