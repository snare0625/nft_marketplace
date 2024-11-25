// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

// Using ERC721 standard
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


import "hardhat/console.sol";

// public means available from the client application
// view means it's noty doing any transaction work

contract NFTMarketPlace is ERC721URIStorage {
    //allows us to use the counter utility.
    using Counters for Counters.Counter;
    // when the first token is minted it'll get a value of zero, the second one is one
    // and then using counters this we'll increment token ids
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;

    // fee to list an nft on the marketplace
    // charge a listing fee.
    uint256 listingPrice = 0.025 ether;

    // declaring the owner of the contract
    // owner earns a commision on every item sold\
    address payable owner;

    // keeping up with all the items that have been created
    // pass in the integer which is the item id and it returns a market item.
    // to fetch a market item, we only need the item id
    mapping(uint256 => MarketItem) private idToMarketItem;

    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    // have an event when a market item is created.
    // this event matches the MarketItem
    event MarketItemCreated (
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    // set the owner as msg.sender
    // the owner of the contract is the one deploying it
    constructor () {
        owner = payable(msg.sender);
    }

    /* Updates the listing price of the contract */
    function updateListingPrice(uint _listingPrice) public payable {
        // 'owner == ms
        require(owner == msg.sender, "Only marketplace owner can update the lsiting price");

        listingPrice = _listingPrice;
    }

    /* Returns the listing price of the contract */
    // when we deploy the contract on the frontend we don't know how much to list it for
    // so we call the contract and get the listing price and make sure we're sending the right amount
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    /* Mints a token and lists it in the marketplace */
    function createToken(string memory tokenURI, uint256 price) public payable returns (uint) {
        _tokenIds.increment();
        // variable that get's the value of the tokenIds (0, 1, 2..)
        uint256 newTokenId = _tokenIds.current();
        // mint the token with
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        createMarketItem(newTokenId, price);
        // we've just minted the token and make it sellable

        // now we can return the id to the client side so we can work with it
        return newTokenId;
    }

    function createMarketItem(uint256 tokenId, uint256 price) private {
        // require a certain CONDITION, in this case price greater than 0
        require(price > 0, "Price must be at least 1 wei");
        // require that the users sending in the transaction is sending in the correct amount
        require(msg.value == listingPrice, "Price must be equal to listingn price");

        // create the mapping for the market items
        // payable(address(0))n is the owner
        // currently there's no owner as the seller is putting it to market so it's an empty address
        // last value is boolean for sold, its false because we just put it so it's not sold yet
        // this is creating the first market item
        idToMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );

        // transfer the ownership of the nft to the contract -> next buyer
        _transfer(msg.sender, address(this), tokenId);
        emit MarketItemCreated(tokenId, msg.sender, address(this), price, false);
    }
}