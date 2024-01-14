const { network, ethers,upgrades  } = require("hardhat");

const {
    networkConfig,
    developmentChains,
} = require("../helper-hardhat-config")
const { verify } = require("../utils/verify.js")

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
    let fishOracle = contractList.fishOracle;
    
    log("----------------------------------------------------");
    const FISHORACLE = await ethers.getContractFactory('FishOracle');
    if (fishOracle) {
        fishOracle = FISHORACLE.attach(usdc);
    } else {
        fishOracle = await upgrades.deployProxy(FISHORACLE, [contractList.usdc_fish_lp_address, contractList.fish], { initializer: 'initialize' });
        await fishOracle.deployed();
    }
    console.log("fishOracle:", contractList.fishOracle);
    
    

    // Verify the deployment
    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("Verifying...");
        await verify(FISHORACLE.address, arguments);
    }

    log("Enter fishoracle with command:");
    const networkName = network.name == "hardhat" ? "localhost" : network.name;
    log(`yarn hardhat run deploy-06-deploy-fishoracle.js --network ${networkName}`);
    log("----------------------------------------------------");
}

module.exports.tags = ["all", "fishoracle"]