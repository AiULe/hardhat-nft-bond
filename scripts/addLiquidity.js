const { ethers,network } = require("hardhat");
const {
    networkConfig,
    developmentChains,
} = require("../helper-hardhat-config");
const { sleep } = require("../utils/sleep.js");

async function addLiquidity() {
    const chainId = network.config.chainId;
    const contractList = {};
    if (chainId == 31337) {
        contractList = networkConfig[chainId]["contractList"];
    } else {
        contractList = networkConfig[chainId]["contractList"];
    }
    const fish = contractList.fish;
    const usdc = contractList.usdc;
    await pancakeFactory.createPair(fish, usdc);
    await sleep(10000);
    var usdc_fish_lp_address = await pancakeFactory.getPair(fish, usdc);
    console.log("usdc_fish_lp_address:", usdc_fish_lp_address);
    contractList.usdc_fish_lp = usdc_fish_lp_address;
    await usdc.approve(contractList.pancakeRouter, '1000000000000000000000000000000'); console.log("usdc.approve:");
    await sleep(10000);
    await fish.approve(contractList.pancakeRouter, '1000000000000000000000000000000'); console.log("fish.approve:");
    await sleep(10000);
    await pancakeRouter.addLiquidity(
        fish.address,
        usdc.address,
        '100000000000000000',//0.1 fish
        '1500000000000000000',//1.5u
        0,
        0,
        deployer.address,
        Math.round(new Date() / 1000) + 1000
    );
    console.log("addLiquidity");
    await sleep(10000);
}

addLiquidity()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })