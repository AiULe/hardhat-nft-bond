const { network, ethers,upgrades  } = require("hardhat");

const {
    networkConfig,
    developmentChains,
} = require("../helper-hardhat-config");
const { verify } = require("../utils/verify.js");
const { sleep } = require("../utils/sleep.js");

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId;
    let contractList = {};
    if (chainId == 31337) {
        contractList = networkConfig[chainId]["contractList"];
    } else {
        contractList = networkConfig[chainId]["contractList"];
    }
    // let fishOracle = contractList.fishOracle;
    
    log("----------------------------------------------------");
    const FishNft = await ethers.getContractFactory('FishNft');
    if (contractList.fishNft) {
        var fishNft = FishNft.attach(contractList.fishNft);
    } else {
        fishNft = await upgrades.deployProxy(FishNft, ["0xFishBone Nft", 'FB-NFT', contractList.fish], { initializer: 'initialize' });
        await fishNft.deployed();
    }
    contractList.fishNft = fishNft.address;
    console.log("fishNft:", contractList.fishNft);
    await sleep(10000);
    
    

    // Verify the deployment
    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("Verifying...");
        await verify(FishNft.address, arguments);
    }

    log("Enter fishNft with command:");
    const networkName = network.name == "hardhat" ? "localhost" : network.name;
    log(`yarn hardhat run deploy-08-deploy-fishNft.js --network ${networkName}`);
    log("----------------------------------------------------");
}

module.exports.tags = ["all", "fishnft"]