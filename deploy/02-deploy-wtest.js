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
    const args = [];
    
    log("----------------------------------------------------");
    await deploy("WTEST",{
        from: deployer,
        log:true,
        args:args,
    });
    
    

    // Verify the deployment
    // if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
    //     log("Verifying...");
    //     await verify(USDCERC20.address, arguments);
    // }

    log("Enter WTEST with command:");
    const networkName = network.name == "hardhat" ? "localhost" : network.name;
    log(`yarn hardhat run deploy-02-deploy-wtest.js --network ${networkName}`);
    log("----------------------------------------------------");
}

module.exports.tags = ["all", "weth9"]