import { ethers, run } from "hardhat";

function sleep(milliseconds) {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}

async function main() {
  const args = [
    "0", // baseRatePerYear
    "39999999998615040", // multiplierPerYear
    "1089999999998841600", // jumpMultiplierPerYear
    "800000000000000000", // kink_
    "0xf42bF799DD9E70605083e38e5a3bd6AAe63A8516"
  ];

  const contract = await ethers.deployContract("LegacyJumpRateModelV2", args);

  await contract.deployed();

  console.log(`contract deployed to ${contract.address}`);

  await sleep(20000);

  await run("verify:verify", {
    address: contract.address,
    constructorArguments: args
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
