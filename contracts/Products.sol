// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Products {
    struct Product {
        uint id;
        string name;
        string image;
        uint price;
        address payable owner;
        bool purchased;
    }

    event ProductCreated(
        uint id,
        string name,
        string image,
        uint price,
        address payable owner,
        bool purchased
    );

    event ProductPurchased(
        uint id,
        string name,
        string image,
        uint price,
        address payable owner,
        bool purchased
    );
}