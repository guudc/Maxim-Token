# GUUDC Token - Smart Contract Documentation

## Overview

GUUDC (GDC) is an ERC20 token with a multi-phase sale structure including Seed Sale, Private Sale, and Pre-Sale. The token implements a tiered pricing system with support for payments in ETH, wBNB, and wSOL using Chainlink price feeds for accurate USD conversions.

## Contract: GUUDC.sol

An ERC20 token with advanced sale mechanisms and multi-chain payment support.

### Key Features

- **Multi-phase Sales**: Three distinct sale phases (Seed, Private, Pre-Sale)
- **Tiered Pricing**: Different price tiers within each sale phase
- **Multi-chain Payments**: Support for ETH, wBNB, and wSOL payments
- **Chainlink Integration**: Real-time price feeds for accurate USD conversions
- **Controlled Distribution**: Only owner can execute sale functions
- **Fixed Supply**: Maximum supply of 200,000,000 tokens

### Token Details

- **Name**: GUUDC
- **Symbol**: GDC
- **Total Supply**: 200,000,000 tokens
- **Decimals**: 18

### Sale Structure

#### Seed Sale (3 Tiers)
- **Tier 1**: 5,000,000 tokens @ $0.000001 USD each
- **Tier 2**: 2,000,000 tokens @ $0.000002 USD each  
- **Tier 3**: 500,000 tokens @ $0.000003 USD each

#### Private Sale (4 Tiers)
- **Tier 1**: 5,625,000 tokens @ $0.000004 USD each
- **Tier 2**: 5,625,000 tokens @ $0.000007 USD each
- **Tier 3**: 5,625,000 tokens @ $0.000010 USD each
- **Tier 4**: 5,625,000 tokens @ $0.000015 USD each

#### Pre-Sale (2 Tiers)
- **Tier 1**: 5,000,000 tokens @ $0.000021 USD each
- **Tier 2**: 5,000,000 tokens @ $0.000042 USD each

### Address Constants

```solidity
// Administration
address immutable PRO_ADMIN = 0x4Fa420BD8B6DaF25FaE43E6102785Ef637915B95;

// Chainlink Price Feeds
address immutable ETH_USD_CHAIN_LINK = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
address immutable BNB_USD_CHAIN_LINK = 0x14e613AC84a31f709eadbdF89C6CC390fDc9540A;
address immutable SOL_USD_CHAIN_LINK = 0x4ffC43a60e009B551865A93d232E33Fce9f01507;

// Wrapped Tokens
address immutable WRAPPED_BNB = 0x9D7f74d0C41E726EC95884E0e97Fa6129e3b5E99;
address immutable WRAPPED_SOL = 0x4ffC43a60e009B551865A93d232E33Fce9f01507;

// Treasury Addresses
address public SEED_SALE_TREASURY = 0x4Fa420BD8B6DaF25FaE43E6102785Ef637915B95;
address public PRIVATE_SALE_TREASURY = 0x4Fa420BD8B6DaF25FaE43E6102785Ef637915B95;
address public PRE_SALE_TREASURY = 0x4Fa420BD8B6DaF25FaE43E6102785Ef637915B95;
```

### Main Functions

#### Seed Sale
```solidity
function seedSale(uint256 amount, uint256 tokenType) external payable onlyOwner returns (uint)
```
- **Purpose**: Purchase tokens during seed sale phase
- **Payment Methods**: ETH (1), wBNB (2), wSOL (3)
- **Access**: Only owner

#### Private Sale
```solidity
function privateSale(uint256 amount, uint256 tokenType) external payable onlyOwner returns (uint)
```
- **Purpose**: Purchase tokens during private sale phase
- **Payment Methods**: ETH (1), wBNB (2), wSOL (3)
- **Access**: Only owner

#### Pre-Sale
```solidity
function preSale(uint256 amount, uint256 tokenType) external payable onlyOwner returns (uint)
```
- **Purpose**: Purchase tokens during pre-sale phase
- **Payment Methods**: ETH (1), wBNB (2), wSOL (3)
- **Access**: Only owner

### Getter Functions

#### Get Equivalent Amount
```solidity
function getEquivAmount(uint256 amount, uint saleType, uint tokenType) external view returns (uint amountToBuy)
```
- **Purpose**: Calculate how many tokens a payment amount would purchase
- **Parameters**: Payment amount, sale type, token type
- **Returns**: Equivalent token amount

#### Get Current Tier
```solidity
function getTier(uint saleType) public view returns(uint8)
```
- **Purpose**: Check current active tier for a sale type
- **Parameters**: Sale type (1=Seed, 2=Private, 3=Pre)
- **Returns**: Current tier number (0 if sale finished)

### Utility Functions

#### Price Conversion
```solidity
function getEthBnbSolUsdPrice(uint256 amount, uint _type) private view returns (uint equivPrice)
```
- **Purpose**: Convert crypto payments to USD value using Chainlink
- **Supported**: ETH, BNB, SOL price feeds
- **Returns**: USD equivalent value

### Installation & Deployment

#### Prerequisites
- Node.js and npm
- Hardhat or Truffle framework
- OpenZeppelin contracts
- Chainlink contracts

#### Dependencies
```bash
npm install @openzeppelin/contracts
npm install @chainlink/contracts
```

#### Deployment
```javascript
// Example deployment script
async function main() {
  const GUUDC = await ethers.getContractFactory("GUUDC");
  const guudc = await GUUDC.deploy();
  
  await guudc.deployed();
  console.log("GUUDC token deployed to:", guudc.address);
}
```

### Usage Workflow

1. **Deployment**: Deploy contract (total supply minted to contract)
2. **Sale Setup**: Configure treasury addresses if different from default
3. **Execute Sales**: Owner calls sale functions with payment details
4. **Token Distribution**: Tokens transferred to buyers automatically
5. **Tier Management**: Contract automatically progresses through tiers

### Payment Process

#### For ETH Payments:
1. User sends ETH to sale function
2. Contract calculates USD value using Chainlink
3. Excess ETH is refunded
4. Tokens transferred to buyer
5. ETH sent to treasury

#### For wBNB/wSOL Payments:
1. User approves token spending first
2. Contract transfers tokens from user to treasury
3. USD value calculated using Chainlink
4. Equivalent tokens transferred to buyer

### Security Features

- **Ownable**: Only contract owner can execute sales
- **Price Oracles**: Chainlink for secure price feeds
- **Threshold Checks**: Prevents dust amount transactions
- **Proper Transfers**: Secure token transfer mechanisms
- **Immutable Constants**: Critical addresses cannot be changed

### Important Considerations

1. **Chainlink Configuration**: Ensure correct price feed addresses for each network
2. **Treasury Management**: Treasury addresses should be secure multi-sig wallets
3. **Sale Timing**: Implement external timing mechanism for sale phases
4. **KYC/AML**: Consider off-chain compliance requirements
5. **Vesting**: May need additional vesting mechanisms for team tokens

### Testing Recommendations

1. **Price Feed Mocking**: Create mock price feeds for testing
2. **Sale Simulation**: Test all sale tiers and payment methods
3. **Edge Cases**: Test with minimum and maximum purchase amounts
4. **Network Testing**: Test on testnets before mainnet deployment
5. **Integration Testing**: Test with frontend applications

### License

MIT License - See SPDX-License-Identifier in contract header

### Future Enhancements

- **Public Sale**: Additional sale phase implementation
- **Vesting Contracts**: Time-locked token distributions
- **Multi-signature**: Enhanced security for treasury operations
- **Dynamic Pricing**: Algorithmic price adjustments
- **Cross-chain**: Support for multiple blockchain networks
- **Governance**: Token holder voting mechanisms

## Conclusion

The GUUDC token contract provides a robust foundation for a multi-phase token sale with tiered pricing and multi-chain payment support. Its integration with Chainlink price oracles ensures accurate USD conversions, while the owner-controlled sale mechanism provides security and control over the distribution process. The contract is well-structured for a professional token launch with clear sale phases and proper fund handling.
