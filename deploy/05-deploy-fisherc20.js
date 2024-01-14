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
    let fish = contractList.fish;
    
    log("----------------------------------------------------");
    const FISHERC20 = await ethers.getContractFactory('FishERC20');
    if (fish) {
        fish = FISHERC20.attach(fish);
        console.log("fish:", fish);
    } else {
        fish = await upgrades.deployProxy(FISHERC20, ['Fish Token', 'FISH', deployer, '100000000000000000'], { initializer: 'initialize' });
        // console.log("fish===>",fish);
        await fish.deployed();
        console.log("fish:", fish.address);
    }
    
    

    // Verify the deployment
    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("Verifying...");
        await verify(FISHERC20.address, arguments);
    }

    log("Enter fish with command:");
    const networkName = network.name == "hardhat" ? "localhost" : network.name;
    log(`yarn hardhat run deploy-05-deploy-fisherc20.js --network ${networkName}`);
    log("----------------------------------------------------");
}

module.exports.tags = ["all", "fisherc20"]