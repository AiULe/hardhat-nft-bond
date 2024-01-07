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
    const contractList = {};
    if (chainId == 31337) {
        contractList = networkConfig[chainId]["contractList"];
    } else {
        contractList = networkConfig[chainId]["contractList"];
    }
    const usdc = contractList.usdc;
    
    log("----------------------------------------------------");
    const USDCERC20 = await ethers.getContractFactory('FishERC20');
    if (usdc) {
        usdc = USDCERC20.attach(contracts.usdc);
    } else {
        usdc = await upgrades.deployProxy(USDCERC20, ['USDC-test', 'USDC-test', deployer.address, '100000000000000000000000000'], { initializer: 'initialize' });
        await usdc.deployed();
        await usdc.waitForDeployment();
    }
    console.log("usdc:", contracts.usdc);
    
    

    // Verify the deployment
    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("Verifying...");
        await verify(USDCERC20.address, arguments);
    }

    log("Enter lottery with command:");
    const networkName = network.name == "hardhat" ? "localhost" : network.name;
    log(`yarn hardhat run deploy/01-deploy.js --network ${networkName}`);
    log("----------------------------------------------------");
}

module.exports.tags = ["all", ""]