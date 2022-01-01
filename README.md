# Ying-Yang
Pay on Ethereum, mint on Starknet.

Although this is part of my experiments with Starknet to get more familiar with it, I believe it could potentially be a solution for a (temporary, hopefully) problem on Starknet. To paliate for lack of support for wrapped eth or other currencies, we split the payment on Ethereum and the minting itself on Starknet.

## Payment contract on Ethereum
A simple contract that accepts eth as payment (and refunds it of course, since it's on Goerli). It works by constructing the proper payload for Starknet which is made of the contract's address on Starknet, the selector of the mint function and the recipient's address.

If you are wondering why the recipient is a `uint256` type and not `address`, it's because we expect users to be represented by smart-contracts on Starknet.

You can interact with the contract [here](https://goerli.etherscan.io/address/0xc1c54da1676a16223474fb1557be295959b20038).

It expects a 0.001 eth payment everytime you mint.

## Minting on Starknet
The contract is an extremely simplified version of the `ERC721`. It just mints a single tokenId to an address and ... that's it. Add two view functions, ` totalSupply` and `ownerOf`to it, and it's done! Ready to be consumed!

You can interact with the contract [here](https://goerli.voyager.online/contract/0x06d752ffe2c6ae926b473937d855051423df4f923ef8ec6cc7fea9115812179a#readContract).