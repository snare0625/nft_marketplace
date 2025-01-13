const hre = require('hardhat');

async function main() {
  // Variable to allow us to deploy instance of our contract
  const NFTMarketPlace = await hre.ethers.getContractFactory('NFTMarketPlace');
  const nftmarketplace = await NFTMarketPlace.deploy();

  await nftmarketplace.deployed();

  console.log('Greeter deployed to:', nftmarketplace.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
