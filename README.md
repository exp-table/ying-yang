# Ying-Yang
Pay on Ethereum, mint on Starknet.

Although this is part of my experiments with Starknet to get more familiar with it, I believe it could potentially be a solution for a (temporary, hopefully) problem on Starknet. To paliate for lack of support for wrapped eth or other currencies, we split the payment on Ethereum and the minting itself on Starknet.

You can play with it [here](https://ying-yang-gamma.vercel.app/)

## Payment contract on Ethereum
A simple contract that accepts eth as payment (and refunds it of course, since it's on Goerli). It works by constructing the proper payload for Starknet which is made of the contract's address on Starknet, the selector of the mint function and the recipient's address.

If you are wondering why the recipient is a `uint256` type and not `address`, it's because we expect users to be represented by smart-contracts on Starknet.

You can interact with the contract [here](https://goerli.etherscan.io/address/0xa46AdF555Efe9A7F69C1e1ee33BEeEb68dE17dd2).

It expects a 0.001 eth payment everytime you mint.

## Minting on Starknet
The contract is the standard `ERC721`, with just the `totalSupply` function taken from `ERC721Enumerable`.

You can interact with the contract [here](https://goerli.voyager.online/contract/0x000af17e06ea9907051522a9db715563a504208fad1651aa9c850296f47a3624#readContract).