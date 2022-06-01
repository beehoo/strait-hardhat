const { ethers } = require('hardhat')

const main = async () => {
  const Strait = await ethers.getContractFactory('Strait')
  const strait = await Strait.deploy()
  await strait.deployed()

  console.log('Strait deployed to: ', strait.address)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })