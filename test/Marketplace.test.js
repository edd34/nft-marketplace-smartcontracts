const { accounts, contract } = require('@openzeppelin/test-environment');
const Web3 = require('web3');
const { assert, expect } = require('chai');
const { expectRevert, expectEvent, balance, time } = require('@openzeppelin/test-helpers');
const SimpleAuction = contract.fromArtifact('SimpleAuction'); // Loads a compiled contract

const ether = 10 ** 18; // 1 ether = 1000000000000000000 wei
const [owner, alice, bob] = accounts;

//const OurBank = contract.fromArtifact('OurBank');
describe("SimpleAuction", () => {

    beforeEach( async () => {
        this.current_time = new Date(Date.now());
        console.log(this.current_time, this.current_time.getTime());
    }

    )

    it("should create a NFT", async () => {
        const mySimpleAuction = await SimpleAuction.new("name", "symb", {from: owner});
        await mySimpleAuction.safeMint(owner, "tokenURI.json", {from: owner});
        
        assert.equal((await mySimpleAuction.totalSupply()).toString(), "1");
        assert.equal((await mySimpleAuction.balanceOf(owner)).toString(), "1");
        assert.equal((await mySimpleAuction.ownerOf(0)).toString(), owner);
    });

    it("should create an auction", async () => {
        current_time = new Date(Date.now());
        const mySimpleAuction = await SimpleAuction.new("name", "symb", {from: owner});
        await mySimpleAuction.safeMint(owner, "test.json", {from: owner});

        await mySimpleAuction.createAuction(0, "auction test", "", 1, current_time.getTime().toString(), {from: owner})
        await mySimpleAuction.bidOnAuction(0, {from: alice, value: 20});
        await mySimpleAuction.bidOnAuction(0, {from: bob, value: 30});

        assert.equal(await mySimpleAuction.getCount(), 1);
        assert.equal(await mySimpleAuction.getBidsCount(0), 2);
        list_auction_owner = await mySimpleAuction.getAuctionsOf(owner)
        console.log("list_auction_owner", list_auction_owner)
        assert.equal(list_auction_owner.length, 1);
        current_bid = await mySimpleAuction.getCurrentBid(0);
        
        console.log(current_bid[0].toString(), current_bid[1])
        assert.equal(current_bid[0].toString(), "30");
        assert.equal(current_bid[1].toString(), bob);

        console.log((await time.latest()).toString())
        await time.increase(300);
        console.log((await time.latest()).toString())
        res = await mySimpleAuction.finalizeAuction(0, {from: owner});
        console.log(res);

        assert.equal((await mySimpleAuction.totalSupply()).toString(), "1");
        assert.equal((await mySimpleAuction.balanceOf(owner)).toString(), "0");
        assert.equal((await mySimpleAuction.balanceOf(bob)).toString(), "1");
        assert.equal((await mySimpleAuction.ownerOf(0)).toString(), bob);

    });
});