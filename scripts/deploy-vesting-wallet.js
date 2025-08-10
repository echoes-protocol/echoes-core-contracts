import { ethers, run } from "hardhat";

function sleep(milliseconds) {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}

async function main() {
  const args = [
    "0xf42bF799DD9E70605083e38e5a3bd6AAe63A8516", // beneficiary
    "1754837836", // startTimestam
    "432000", // durationSeconds
  ];

  const contract = await ethers.deployContract("EchoesVestingWallet", args);

  await contract.deployed();

  console.log(`contract deployed to ${contract.address}`);

  await sleep(20000);

  await run("verify:verify", {
    address: contract.address,
    constructorArguments: args,
    contract: "contracts/EchoesVestingWallet.sol:EchoesVestingWallet"
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
