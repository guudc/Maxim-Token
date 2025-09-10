/**
 * @title MAXIM TOKEN
 * @dev This smart contract handles the MAXIM token.
 * @author GOODNESS E. (COAT)
 * @notice This contract is owned by MAXIM PAY, Inc.
 * @dev Created on 22nd of May, 2024.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/* IMPORT STATEMENTS */
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; 
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


contract MAXIM is ERC20, Ownable {

    /* CONSTANTS */
    uint256 immutable TOTAL_SUPPLY = 200_000_000;
    uint256 immutable SALE_THRESHOLD_AMOUNT = 1;
    address immutable PRO_ADMIN = 0x4Fa420BD8B6DaF25FaE43E6102785Ef637915B95;
    address immutable ETH_USD_CHAIN_LINK = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    address immutable BNB_USD_CHAIN_LINK = 0x14e613AC84a31f709eadbdF89C6CC390fDc9540A; //BNB MAINNET, USE ONLY FOR PRODUCTION
    address immutable SOL_USD_CHAIN_LINK = 0x4ffC43a60e009B551865A93d232E33Fce9f01507; //SOL MAINNET, USE ONLY FOR PRODUCTION
    address immutable WRAPPED_BNB = 0x9D7f74d0C41E726EC95884E0e97Fa6129e3b5E99;
    address immutable WRAPPED_SOL = 0x4ffC43a60e009B551865A93d232E33Fce9f01507;
    

    /* VARIABLES */
    uint256[3] public SEED_SALE = [5_000_000E18, 2_000_000E18, 500_000E18];
    uint256[3] SEED_SALE_USD_PRICE = [1_000_000, 2_000_000, 3_000_000];
    uint256[4] public PRIVATE_SALE = [5_625_000E18, 5_625_000E18, 5_625_000E18, 5_625_000E18];
    uint256[4] PRIVATE_SALE_USD_PRICE = [4_000_000, 7_000_000, 10_000_000, 15_000_000];
    uint256[2] public PRE_SALE = [5_000_000E18, 5_000_000E18];
    uint256[2] PRE_SALE_USD_PRICE = [21_000_000, 42_000_000];
    /* ADDRESS */
    address public SEED_SALE_TREASURY = 0x4Fa420BD8B6DaF25FaE43E6102785Ef637915B95;
    address public PRIVATE_SALE_TREASURY = 0x4Fa420BD8B6DaF25FaE43E6102785Ef637915B95;
    address public PRE_SALE_TREASURY = 0x4Fa420BD8B6DaF25FaE43E6102785Ef637915B95;
    

    constructor() ERC20("MAXIM", "MXM") {
       //mint the total supply
       _mint(address(this), TOTAL_SUPPLY * 1E18); 
       //transferOwnership(PRO_ADMIN); 
    }

    /** SALES FUNCTIONS **/

    /** SEED SALE
        Payments in eth, wBNB, wSOL 
    **/
    function seedSale(uint256 amount, uint256 tokenType) external payable onlyOwner returns (uint) {
        uint8 currentTier = getTier(1); //get the tier
        require(currentTier > 0, "Seed sale has finished"); //check if seed sale has finish
        uint256 usdEquiv = getEthBnbSolUsdPrice(amount, tokenType); //get the usd equivalent
        currentTier = currentTier - 1;
        uint amountToBuy = (1E18/SEED_SALE_USD_PRICE[currentTier]) * usdEquiv;
        //The requires
        require((SEED_SALE[0] + SEED_SALE[1] + SEED_SALE[2]) >= amountToBuy, "Insufficient MAXIM tokens available for sale");
        require((SEED_SALE[0] + SEED_SALE[1] + SEED_SALE[2]) <= totalSupply(), "Insufficient MAXIM tokens available for sale");
        require(SEED_SALE[currentTier] >= amountToBuy, "Insufficient MAXIM tokens available for sale");
        if(tokenType == 1) {
            //transfer any excess back to sender
            require(msg.value >= amount, "Insufficient ETH available for purchase");
            payable(msg.sender).transfer(msg.value - amount);
        }
        else if(tokenType == 2){
            //buying with wbnb
            require(IERC20(WRAPPED_BNB).balanceOf(msg.sender) >= amount, "Insufficient WBNB available for purchase");
            //transfer the WBNB to treasury
            IERC20(WRAPPED_BNB).transferFrom(msg.sender, SEED_SALE_TREASURY, amount);
        }
        else if(tokenType == 3){
            //buying with wsol
            require(IERC20(WRAPPED_SOL).balanceOf(msg.sender) >= amount, "Insufficient WSOL available for purchase");
            //transfer the WSOL to treasury
            IERC20(WRAPPED_SOL).transferFrom(msg.sender, SEED_SALE_TREASURY, amount);
        }
        //substract the amount bought
        SEED_SALE[currentTier] = SEED_SALE[currentTier] - amountToBuy;
        //check if the tierhas ended
        if(SEED_SALE[currentTier] <= SALE_THRESHOLD_AMOUNT) {
            if(currentTier < 2) {
                SEED_SALE[currentTier + 1] = SEED_SALE[currentTier + 1] + SEED_SALE[currentTier];
            }
        }
        //transfer the tokens back to the user
        _transfer(address(this), msg.sender, amountToBuy);
        return amountToBuy;
    }
    /** PRIVATE SALE
        Payments in eth, wBNB, wSOL
    **/
    function privateSale(uint256 amount, uint256 tokenType) external payable onlyOwner returns (uint) {
        uint8 currentTier = getTier(2); //get the tier
        require(currentTier > 0, "Private sale has finished"); //check if private sale has finish
        uint256 usdEquiv = getEthBnbSolUsdPrice(amount, tokenType); //get the usd equivalent
        currentTier = currentTier - 1;
        uint amountToBuy = (1E18/PRIVATE_SALE_USD_PRICE[currentTier]) * usdEquiv;
        //The requires
        require((PRIVATE_SALE[0] + PRIVATE_SALE[1] + PRIVATE_SALE[2] + PRIVATE_SALE[3]) >= amountToBuy, "Insufficient MAXIM tokens available for sale");
        require((PRIVATE_SALE[0] + PRIVATE_SALE[1] + PRIVATE_SALE[2] + PRIVATE_SALE[3]) <= totalSupply(), "Insufficient MAXIM tokens available for sale");
        require(PRIVATE_SALE[currentTier] >= amountToBuy, "Insufficient MAXIM tokens available for sale");
        if(tokenType == 1) {
            //transfer any excess back to sender
            require(msg.value >= amount, "Insufficient ETH available for purchase");
            payable(msg.sender).transfer(msg.value - amount);
        }
        else if(tokenType == 2){
            //buying with wbnb
            require(IERC20(WRAPPED_BNB).balanceOf(msg.sender) >= amount, "Insufficient WBNB available for purchase");
            //transfer the WBNB to treasury
            IERC20(WRAPPED_BNB).transferFrom(msg.sender, PRIVATE_SALE_TREASURY, amount);
        }
        else if(tokenType == 3){
            //buying with wsol
            require(IERC20(WRAPPED_SOL).balanceOf(msg.sender) >= amount, "Insufficient WSOL available for purchase");
            //transfer the WSOL to treasury
            IERC20(WRAPPED_SOL).transferFrom(msg.sender, PRIVATE_SALE_TREASURY, amount);
        }
        //substract the amount bought
        PRIVATE_SALE[currentTier] = PRIVATE_SALE[currentTier] - amountToBuy;
        //check if the tierhas ended
        if(PRIVATE_SALE[currentTier] <= SALE_THRESHOLD_AMOUNT) {
            if(currentTier < 3) {
                PRIVATE_SALE[currentTier + 1] = PRIVATE_SALE[currentTier + 1] + PRIVATE_SALE[currentTier];
            }
        }
        //transfer the tokens back to the user
        _transfer(address(this), msg.sender, amountToBuy);
        return amountToBuy;
    }
    /** PRE SALE
        Payments in eth, wBNB, wSOl
    **/
    function preSale(uint256 amount, uint256 tokenType) external payable onlyOwner returns (uint) {
        uint8 currentTier = getTier(2); //get the tier
        require(currentTier > 0, "Pre sale has finished"); //check if pre sale has finish
        uint256 usdEquiv = getEthBnbSolUsdPrice(amount, tokenType); //get the usd equivalent
        currentTier = currentTier - 1;
        uint amountToBuy = (1E18/PRE_SALE_USD_PRICE[currentTier]) * usdEquiv;
        //The requires
        require((PRE_SALE[0] + PRE_SALE[1]) >= amountToBuy, "Insufficient MAXIM tokens available for sale");
        require((PRE_SALE[0] + PRE_SALE[1]) <= totalSupply(), "Insufficient MAXIM tokens available for sale");
        require(PRE_SALE[currentTier] >= amountToBuy, "Insufficient MAXIM tokens available for sale");
        if(tokenType == 1) {
            //transfer any excess back to sender
            require(msg.value >= amount, "Insufficient ETH available for purchase");
            payable(msg.sender).transfer(msg.value - amount);
        }
        else if(tokenType == 2){
            //buying with wbnb
            require(IERC20(WRAPPED_BNB).balanceOf(msg.sender) >= amount, "Insufficient WBNB available for purchase");
            //transfer the WBNB to treasury
            IERC20(WRAPPED_BNB).transferFrom(msg.sender, PRE_SALE_TREASURY, amount);
        }
        else if(tokenType == 3){
            //buying with wsol
            require(IERC20(WRAPPED_SOL).balanceOf(msg.sender) >= amount, "Insufficient WSOL available for purchase");
            //transfer the WSOL to treasury
            IERC20(WRAPPED_SOL).transferFrom(msg.sender, PRE_SALE_TREASURY, amount);
        }
        //substract the amount bought
        PRE_SALE[currentTier] = PRE_SALE[currentTier] - amountToBuy;
        //check if the tierhas ended
        if(PRE_SALE[currentTier] <= SALE_THRESHOLD_AMOUNT) {
            if(currentTier < 1) {
                PRE_SALE[currentTier + 1] = PRE_SALE[currentTier + 1] + PRE_SALE[currentTier];
            }
        }
        //transfer the tokens back to the user
        _transfer(address(this), msg.sender, amountToBuy);
        return amountToBuy;
    }


    /** GETTERS FUNCTIONS **/

    /** Get the amount of MAXIM token a certain amount would purchase **/
    function getEquivAmount (uint256 amount, uint saleType, uint tokenType) external view returns (uint amountToBuy) {
        //check for seed sale
        amountToBuy = 0;
        if(saleType == 1) {
            uint8 currentTier = getTier(1); //get the tier
            require(currentTier > 0, "Seed sale has finished"); //check if seed sale has finish
            currentTier = currentTier - 1;
            uint256 usdEquiv = getEthBnbSolUsdPrice(amount, tokenType); //get the usd equivalent
            amountToBuy = (1E18/SEED_SALE_USD_PRICE[currentTier]) * usdEquiv;
        }
        else if(saleType == 2) {
            uint8 currentTier = getTier(2); //get the tier
            require(currentTier > 0, "Private sale has finished"); //check if seed sale has finish
            currentTier = currentTier - 1;
            uint256 usdEquiv = getEthBnbSolUsdPrice(amount, tokenType); //get the usd equivalent
            amountToBuy = (1E18/PRIVATE_SALE_USD_PRICE[currentTier]) * usdEquiv;
        }
        else if(saleType == 3) {
            uint8 currentTier = getTier(2); //get the tier
            require(currentTier > 0, "Pre sale has finished"); //check if seed sale has finish
            currentTier = currentTier - 1;
            uint256 usdEquiv = getEthBnbSolUsdPrice(amount, tokenType); //get the usd equivalent
            amountToBuy = (1E18/PRE_SALE_USD_PRICE[currentTier]) * usdEquiv;
        }
    }

    /** Get the current tier of the available sales **/
    function getTier(uint saleType) public view returns(uint8) {
        if(saleType == 1) {
            //seed sale
            for(uint8 i=0;i<=2;i++) {
                if(SEED_SALE[i] > SALE_THRESHOLD_AMOUNT) {
                    return i + 1;
                }
            }
        }
        else if(saleType == 2) {
            //private sale
            for(uint8 i=0;i<=3;i++) {
                if(PRIVATE_SALE[i] > SALE_THRESHOLD_AMOUNT) {
                    return i + 1;
                }
            }
        }
        else if(saleType == 3) {
            //pre sale
            for(uint8 i=0;i<=1;i++) {
                if(PRE_SALE[i] > SALE_THRESHOLD_AMOUNT) {
                    return i + 1;
                }
            }
        }
        return 0;
    }

    /** UTILS **/

    /** Calculate pricing for eth or bnb **/
    function getEthBnbSolUsdPrice (uint256 amount, uint _type) private view returns (uint equivPrice) {
        AggregatorV3Interface priceFeed;
        //eth price feed
        uint decimal = 1E18;
        return 1;
        if(_type == 1){ 
            priceFeed = AggregatorV3Interface(ETH_USD_CHAIN_LINK);
        } 
        else if(_type == 2){
            //bnb price feed
            priceFeed = AggregatorV3Interface(BNB_USD_CHAIN_LINK);
        }
        else {
            //sol price feed
            priceFeed = AggregatorV3Interface(SOL_USD_CHAIN_LINK);
            decimal = 1E9;
        }
        (,int price,,,) = priceFeed.latestRoundData();
        price = price / 1E8;
        //get the dollar equivalent for the amount sent
        equivPrice = ((uint(price)*amount)/decimal);
    }

    
}