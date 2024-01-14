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
    const FACTORYADDR = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
    const WETHADDR = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
    if (chainId == 31337) {
        contractList = networkConfig[chainId]["contractList"];
    } else {
        contractList = networkConfig[chainId]["contractList"];
    }
    let pancakeRouter = contractList.pancakeRouter;
    const args = [FACTORYADDR,WETHADDR];
    
    log("----------------------------------------------------");
    const PancakeRouter = await ethers.getContractFactory('PancakeRouter');
    if (pancakeRouter) {
        pancakeRouter = PancakeRouter.attach(pancakeRouter);
    } else {
        await deploy("PancakeRouter",{
            from: deployer,
            log:true,
            args:args,
        })
    }
    
    

    // Verify the deployment
    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("Verifying...");
        await verify(PancakeRouter.address, arguments);
    }

    log("Enter pancakerouter with command:");
    const networkName = network.name == "hardhat" ? "localhost" : network.name;
    log(`yarn hardhat run deploy-03-deploy-pancakerouter.js --network ${networkName}`);
    log("----------------------------------------------------");
}

module.exports.tags = ["all", "pancakerouter"]