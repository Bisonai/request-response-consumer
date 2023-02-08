import { ethers } from 'hardhat'

async function main() {
  const requestResponseConsumer = await ethers.getContract('RequestResponseConsumer')

  const callbackGasLimit = 500_000
  const numWords = 1

  const txReceipt = await (
    await requestResponseConsumer.requestDataDirectPayment(callbackGasLimit, {
      value: ethers.utils.parseEther('1.0')
    })
  ).wait()

  console.log(txReceipt)
  console.log('Requested data using direct payment')
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
