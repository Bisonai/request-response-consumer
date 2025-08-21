# Request-Response Consumer

Consumer smart contract that utilizes Request-Response functionality from [Orakl Network](https://orakl.network).

Internally, the scripts access following smart contracts:

Kairos

- `Prepayment` ([0x8d3A1663d10eEb0bC9C9e537e1BBeA69383194e7](https://kairos.kaiascan.io/account/0x8d3A1663d10eEb0bC9C9e537e1BBeA69383194e7))
- `RequestResponseCoordinator` ([0x5fe8a7445bFDB2Cd6d9f1DcfB3B33D8c365FFdB0](https://kairos.kaiascan.io/account/0x5fe8a7445bFDB2Cd6d9f1DcfB3B33D8c365FFdB0))

Mainnet

- `Prepayment` ([0xc2C88492Cf7e5240C3EB49353539E75336960600](https://www.kaiascan.io/account/0xc2C88492Cf7e5240C3EB49353539E75336960600))
- `RequestResponseCoordinator` ([0x159F3BB6609B4C709F15823F3544032942106042](https://www.kaiascan.io/account/0x159F3BB6609B4C709F15823F3544032942106042))

If you want to access different deployments of `Prepayment` or `RequestResponseCoordinator`, you can change it inside `hardhat.config.ts` in `namedAccounts` property.

## Prerequisites

Create a copy of `.env.example` file and fill in values for `PROVIDER`, and `MNEMONIC` or `PRIV_KEY` (the difference is explained below) environment variables.
These variables will be used for connection to JSON-RPC endpoint, deployment and use of your [`RequestResponseConsumer` smart contract](contracts/RequestResponseConsumer.sol).

```shell
cp .env.example .env
```

`PROVIDER` can be set to any JSON-RPC endpoint.
The list of free available JSON-RPC endpoint can be found in [official Kaia documentation](https://docs.kaia.io/references/public-en/).

This repository supports connection to wallet either through mnemonic or private key.

### Mnemonic

`MNEMONIC` can be generated using [npm mnemonics package](https://www.npmjs.com/package/mnemonics).

```shell
npx mnemonics
```

After mnemonic is generated, store it in `MNEMONIC` variable inside of .env file.

Now you need to convert it to public address and fund it with KAIA.
If you do not have any KAIA in your account, you cannot deploy smart contracts or make any transactions.

You can convert your newly generated mnemonic with following hardhat task.

Please replace the `MNENONIC` with your mnemonic and run the command below.

```shell
npx hardhat address --mnemonic ${MNEMONIC}
```

The script will print out a public address corresponding to your mnemonic.
Then, you can use this address to receive free KAIA using [Kairos faucet](https://www.kaia.io/faucet).

### Private key

If you already have a wallet, you can reuse its private key, and connect to JSON-RPC endpoint with it.
In case you use Metamask, read [how to export an account's private key.](https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-export-an-account-s-private-key).
After you extract private key, store it in `PRIV_KEY` variable inside of `.env` file.

## Installation

```shell
yarn install
```

## Compilation

```shell
yarn compile
```

## Deploy

```shell
npx hardhat deploy --network kairos
```

If you are using [orakl-repository](https://github.com/Bisonai/orakl/) to run a local node, you can also deploy this `RequestResponseConsumer` on your local node. The `Prepayment` and `RequestResponseCoordinator` addresses in [hardhat.config.ts](hardhat.config.ts) `namedAccounts` are configured properly to be used locally.

## Get Estimated Service Fee

Prior to creating an account, you have the option to retrieve the estimated service fee for a single Request-Response data request. To do this, you can run the provided script using the following command:

```shell
npx hardhat run scripts/get-estimated-service-fee.ts --network kairos
```

Executing the script will provide you with the cost associated with a single request. This information will help you determine the amount you need to fund your account accordingly to meet your specific requirements.

## Create and fund account

There are two types of payments supported by Orakle Network Request-Response: **Prepayment** and **Direct Payment**.

**Prepayment** requires user to create account and fund it with KAIA before being able to use it.
The script below will create a new account and deposit `5` KAIA from address corresponding to your mnemonic or private key from `.env` file.

If you prefer to use Orakl Network Request-Response without having a long-lasting account, you can use **Direct Payment** method.
In such case, you can skip the following command and go directly to **Request data with Direct Payment**.

```shell
npx hardhat run scripts/create-and-fund-account.ts --network kairos
```

After successfully executing the command above, set the value of environment variable `ACC_ID` inside of `.env` file to account ID that was generated using the script above.
If you do not do it, the Request-Response using Prepayment won't be working properly.
After setting the `ACC_ID` in `.env` file, you can move to the next step **Request data with Prepayment**.

If you'd like to use your existing prepayment account, set your account id in the `.env` file and add your deployed consumer to your account by executing the hardhat `addConsumer` task (described in more detail below). Note that providing `account-id` parameter is optional if your account id is already in the `.env` file and `consumer` parameter is also optional if you've deployed your consumer using hardhat under this repository.

## Request data & Read response

Before running following scripts, one must deploy `RequestResponseConsumer` smart contract.
To deploy `RequestResponseConsumer`, run `npx hardhat deploy --network kairos`.

### Request data with Prepayment

```shell
npx hardhat run scripts/request-data.ts --network kairos
```

### Request data with Direct Payment

```shell
npx hardhat run scripts/request-data-direct.ts --network kairos
```

### Read response

```shell
npx hardhat run scripts/read-response.ts --network kairos
```

## Hardhat Tasks

The following tasks allow for more finer control over experimentation with the example code in this repository.

### Create a new account

```shell
npx hardhat createAccount --network kairos
```

### Deposit to an account

After you have created an account, you can deposit $KAIA to it anytime using the command below.

```shell
npx hardhat deposit \
    --account-id $ACCOUNT \
    --amount $AMOUNT \
    --network $NETWORK
```

### Withdraw from an account

To withdraw the remaining balance from an account, you can use the command below.

```shell
npx hardhat withdraw \
    --account-id $ACCOUNT \
    --amount $AMOUNT \
    --network $NETWORK
```

### Add a consumer

Add consumer contract to account.
Then, the consumer contract will be able to request for Request-Response service.

```shell
npx hardhat addConsumer \
    --consumer $CONSUMERADDRESS \
    --account-id $ACCOUNT \
    --network $NETWORK
```

### Remove a consumer

Remove a consumer contract from an account.
Then, the consumer contract will not be able to request for Request-Response service anymore.

```shell
npx hardhat removeConsumer \
    --consumer ${CONSUMERADDRESS} \
    --account-id ${ACCOUNT} \
    --network ${NETWORK}
```
