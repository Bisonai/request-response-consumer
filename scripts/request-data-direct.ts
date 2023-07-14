import { ethers } from 'hardhat'
import { estimateServiceFee } from './get-estimated-service-fee'

async function main() {
  const requestResponseConsumer = await ethers.getContract('RequestResponseConsumer')

  const callbackGasLimit = 500_000
  const estimatedServiceFee = await estimateServiceFee()

  const txReceipt = await (
    await requestResponseConsumer.requestDataDirectPayment(callbackGasLimit, {
      value: ethers.utils.parseEther(estimatedServiceFee.toString())
    })
  ).wait()

  console.log(txReceipt)
  console.log('Requested data using direct payment')
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
