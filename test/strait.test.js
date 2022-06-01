const { expect } = require('chai')
const { ethers } = require('hardhat')

const address = '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266'

describe('Strait', () => {
  it('', async () => {
    const Strait = await ethers.getContractFactory('Strait')
    const strait = await Strait.deploy()
    await strait.deployed()

    await strait.mint(3, 'www.hongmasoft.com')
    
    const result = await strait.tokensOfOwner(address)
    console.log(result)

    // expect(await token.mint(1)).to.equal('')
  })
})