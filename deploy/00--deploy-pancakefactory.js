const { network, ethers,upgrades  } = require("hardhat");

const {
    networkConfig,
    developmentChains,
} = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId;
    let contractList = {};
    const FEETOSETTER = "0x49A0804c9D0DdA121C6a15bb46d528DBAe64f461";
    if (chainId == 31337) {
        contractList = networkConfig[chainId]["contractList"];
    } else {
        contractList = networkConfig[chainId]["contractList"];
    }
    let pancakeFactory = contractList.pancakeFactory;
    const args = [FEETOSETTER];
    
    log("----------------------------------------------------");
    const PancakeFactory = await ethers.getContractFactory('PancakeFactory');
    if (pancakeFactory) {
        pancakeFactory = PancakeFactory.attach(pancakeFactory);
    } else {
        await deploy("PancakeFactory",{
            from: deployer,
            log:true,
            args:args,
        })
    }
    console.log("pancakeFactory:", pancakeFactory);
    
    

    // Verify the deployment
    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("Verifying...");
        await verify(USDCERC20.address, arguments);
    }

    log("Enter pancakeFactory with command:");
    const networkName = network.name == "hardhat" ? "localhost" : network.name;
    log(`yarn hardhat run deploy/00-deploy-pancakeFactory.js --network ${networkName}`);
    log("----------------------------------------------------");
}

module.exports.tags = ["all", "pancakefactory"]