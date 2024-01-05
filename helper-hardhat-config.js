const { ethers } = require("hardhat")

const networkConfig = {
    default: {
        name: "hardhat",
    },
    31337: {
        name: "localhost",
    },
    11155111: {
        name: "sepolia",
    },
    1: {
        name: "mainnet",
    },
}

const developmentChains = ["hardhat", "localhost"];
const VERIFICATION_BLOCK_CONFIRMATIONS = 6;
const frontEndContractsFile = "../nextjs-smartcontract-lottery-fcc/constants/contractAddresses.json";
const frontEndAbiFile = "../nextjs-smartcontract-lottery-fcc/constants/abi.json";
const contractList = {
    pancakeRouter: '',
    pancakeFactory: '',
    multiSignature: '',
    multiSignatureToSToken: '',
    usdc: '',
    fish: '',
    fishOracle: '',
    sFISH: '',
    dev: '',
    op: '',
    usdc_fish_lp: '',
    fishNft: '',
    usdcBuyNftLogic: ''
}

module.exports = {
    networkConfig,
    developmentChains,
    VERIFICATION_BLOCK_CONFIRMATIONS,
    frontEndContractsFile,
    frontEndAbiFile,
}