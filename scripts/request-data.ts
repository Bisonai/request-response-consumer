import { ethers } from 'hardhat'
import dotenv from 'dotenv'

dotenv.config()

async function main() {
  const ACC_ID = process.env.ACC_ID
  if (!ACC_ID) {
    console.error('ACC_ID not defined in .env file')
  } else {
    const requestResponseConsumer = await ethers.getContract('RequestResponseConsumer')

    const callbackGasLimit = 500_000
    const txReceipt = await (
      await requestResponseConsumer.requestData(ACC_ID, callbackGasLimit)
    ).wait()
    console.log(txReceipt)
    console.log('Requested data using prepayment')
  }
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
