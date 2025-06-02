import { ethers, run } from "hardhat";

function sleep(milliseconds) {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}

async function main() {
  const args = [
    "OTest",
    "OT"
  ];

  const contract = await ethers.deployContract("OTest", args);

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
