import { ethers } from 'hardhat'

async function main() {
  const userContract = await ethers.getContract('RequestResponseConsumer')
  console.log('RequestResponseConsumer', userContract.address)

  const response = await userContract.sResponse()
  console.log(`Response ${response}`)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
