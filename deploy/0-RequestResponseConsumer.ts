import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, network } = hre
  const { deploy } = deployments
  const { deployer, requestResponseCoordinator: coordinatorAddress } = await getNamedAccounts()

  console.log('0-RequestResponseConsumer.ts')

  if (network.name != 'baobab') {
    console.log('Skipping')
    return
  }

  await deploy('RequestResponseConsumer', {
    args: [coordinatorAddress],
    from: deployer,
    log: true
  })
}

export default func
func.id = 'deploy-request-response-consumer'
func.tags = ['request-response-consumer']
