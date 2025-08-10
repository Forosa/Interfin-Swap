# InterfinSwap

InterfinSwap is a decentralized exchange (DEX) and automated market maker (AMM) protocol built for the Binance Smart Chain (BSC). It enables users to swap BEP-20 tokens, provide liquidity, and earn rewards in a trustless, permissionless environment.

## Features

- **Decentralized Trading**: Swap BEP-20 tokens directly from your wallet.
- **Automated Market Making**: Uses smart contracts to provide always-available liquidity.
- **Liquidity Pools**: Users can add and withdraw liquidity to earn a share of swap fees.
- **Secure and Audited**: Built with OpenZeppelin Contracts and following best security practices.
- **Fast and Low Fees**: Runs on BSC, offering quick transactions with minimal gas costs.

## Getting Started

### Prerequisites

- Node.js (v16 or later)
- npm
- Hardhat

### Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/yourusername/interfinswap.git
   cd interfinswap
   ```
2. Install dependencies:
   ```sh
   npm install
   ```

### Configuration

1. Copy `.env.example` to `.env` and fill in your private keys and RPC URLs.

### Deployment

- **Testnet:**
  ```sh
  npx hardhat run scripts/deploy.js --network bscTestnet
  ```
- **Mainnet:**
  ```sh
  npx hardhat run scripts/deploy.js --network bscMainnet
  ```

### Testing

Run the smart contract tests:
```sh
npx hardhat test
```

## Contracts

- Written in Solidity ^0.8.20
- Uses [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts) for security and upgradability.

## Security

- Follows best practices with OpenZeppelin library
- Please audit the code before using in production

## License

MIT

---

**For more details, see the [docs](./docs) folder or open an issue.**



