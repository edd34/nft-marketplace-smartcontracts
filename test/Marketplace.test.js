const { accounts, contract } = require('@openzeppelin/test-environment');
const Web3 = require('web3');
const { assert } = require('chai');
const { expectRevert, expectEvent, balance } = require('@openzeppelin/test-helpers');
const SimpleAuction = contract.fromArtifact('SimpleAuction'); // Loads a compiled contract
const NFT = contract.fromArtifact('NFT'); // Loads a compiled contract

const ether = 10 ** 18; // 1 ether = 1000000000000000000 wei
const [owner, alice, bob] = accounts;
const OurBank = contract.fromArtifact('SimpleAuction'); // Loads a compiled contract

//const OurBank = contract.fromArtifact('OurBank');
describe("SimpleAuction", () => {
    it("should check something", async () => {
        const mySimpleAuction = await SimpleAuction.new("test", "tst", {from: owner});
        const NFT_contract = await NFT.at(await mySimpleAuction.getNFTAddress());

        await NFT_contract.safeMint(alice, "test.json", {from: mySimpleAuction.address});
        await NFT_contract.safeMint(alice, "test.json", {from: mySimpleAuction.address});

        const block_deadline_date = new Date(Date.UTC('2022','01','13','23','31','30'));

        await mySimpleAuction.createAuction(0, "auction test", "", 1*ether, block_deadline_date.getTime())
    });
});