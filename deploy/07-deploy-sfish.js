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
    const SFISH = await ethers.getContractFactory('sFISH');
    if (contractList.sFISH) {
        var sFISH = SFISH.attach(contractList.sFISH);
    } else {
        sFISH = await SFISH.deploy(contractList.fish);
        await sleep(10000);
        //定价
        await contractList.fish.approve(sFISH.address, '1000000000000000000000000000000'); console.log("fish.approve:sFISH");
        await sleep(10000);
        await contractList.fish.setExecutor(deployer, true); console.log("fish.setExecutor deployer.address");
        await sleep(10000);
        await contractList.fish.mint(deployer.address, '1000000000000000000');
        await sleep(10000);
        await sFISH.mint('1000000000000000000'); console.log("sFISH.mint");
    }
    contractList.sFISH = sFISH.address;
    console.log("sFISH:", contractList.sFISH);
    await sleep(10000);
    
    

    // Verify the deployment
    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("Verifying...");
        await verify(SFISH.address, arguments);
    }

    log("Enter sfish with command:");
    const networkName = network.name == "hardhat" ? "localhost" : network.name;
    log(`yarn hardhat run deploy-07-deploy-sfish.js --network ${networkName}`);
    log("----------------------------------------------------");
}

module.exports.tags = ["all", "sfish"]