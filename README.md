# HooniLocker - V4 Fee Management for $HOONI

Simple LP fee collection contract for Hoonicorn ($HOONI), the first V4 Unicorn on Unichain. Built for the pioneering Uniswap V4 LP position that kickstarted liquidity on Unichain.

## About
HooniLocker uses Uniswap V4's novel command pattern to manage fee collection through zero-liquidity decrease operations. The contract enables secure, permissioned fee claims while maintaining position liquidity.

## Features
- UniswapV4 LP fee collection
- Whitelisted caller system
- Configurable fee recipient
- Locks the liquidity NFT forever

## Links
- Website: https://hoonicornerc20.eth.limo
- Telegram: https://t.me/HOONI_ERC20
- Twitter: https://x.com/HOONI_ERC20
- Trade: https://swap.hoonicornerc20.eth.limo

*"Bringing Uniswap V4 to Unichain, one hoonicorn at a time 🦄"*


## Getting Started

Clone the repository and then run inside the project folder:

```sh
$ bun install # install Solhint, Prettier, and other Node.js deps
```

If this is your first time with Foundry, check out the
[installation](https://github.com/foundry-rs/foundry#installation) instructions.


## Writing Tests

To write a new test contract, you start by importing `Test` from `forge-std`, and then you inherit it in your test
contract. Forge Std comes with a pre-instantiated [cheatcodes](https://book.getfoundry.sh/cheatcodes/) environment
accessible via the `vm` property. If you would like to view the logs in the terminal output, you can add the `-vvv` flag
and use [console.log](https://book.getfoundry.sh/faq?highlight=console.log#how-do-i-use-consolelog).


## Usage

This is a list of the most frequently needed commands.

### Build

Build the contracts:

```sh
$ forge build
```

### Clean

Delete the build artifacts and cache directories:

```sh
$ forge clean
```

### Compile

Compile the contracts:

```sh
$ forge build
```

### Format

Format the contracts:

```sh
$ forge fmt
```

### Gas Usage

Get a gas report:

```sh
$ forge test --gas-report
```

### Lint

Lint the contracts:

```sh
$ bun run lint
```

### Test

Run the tests:

```sh
$ forge test
```
