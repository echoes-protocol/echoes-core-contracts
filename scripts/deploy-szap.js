import { ethers, run } from "hardhat";

function sleep(milliseconds) {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}

async function main() {
  const args = [
    "0x039e2fB66102314Ce7b64Ce5Ce3E5183bc94aD38", // address of wS
    "0xFFf304eD5Fc1A9d83Cd2d4666DafAa348D540772" // address of underlying cToken
  ];

  const contract = await ethers.deployContract("SZap", args);

  await contract.deployed();

  console.log(`contract deployed to ${contract.address}`);

  await sleep(20000);

  await run("verify:verify", {
    address: contract.address,
    constructorArguments: args,
    contract: "contracts/SZap.sol:SZap"
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
