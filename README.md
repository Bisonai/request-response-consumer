# Request-Response Consumer

Consumer smart contract that utilizes Request-Response functionality from [Orakl Network](https://orakl.network).

Internally, the scripts access following smart contracts:

Baobab

- `Prepayment` ([0xf37a736b476fCEaB261371A3B3B330772630b0bF](https://baobab.klaytnfinder.io/account/0xf37a736b476fCEaB261371A3B3B330772630b0bF))
- `RequestResponseCoordinator` ([0x9c73342afD279Cb3106a8F45788973F512d9e40a](https://baobab.klaytnfinder.io/account/0x9c73342afD279Cb3106a8F45788973F512d9e40a))

Cypress

- `Prepayment` ([0xCD54643C2Cd905e31d1ca1bF6617cbA9746F2e37](https://www.klaytnfinder.io/account/0xCD54643C2Cd905e31d1ca1bF6617cbA9746F2e37))
- `RequestResponseCoordinator` ([0x5bd3e5864afdad872f3b99c030600ba25fdfa293](https://www.klaytnfinder.io/account/0x5bD3E5864AfDad872F3b99c030600bA25FdfA293))

If you want to access different deployments of `Prepayment` or `RequestResponseCoordinator`, you can change it inside `hardhat.config.ts` in `namedAccounts` property.

## Prerequisites

Create a copy of `.env.example` file and fill in values for `PROVIDER`, and `MNEMONIC` or `PRIV_KEY` (the difference is explained below) environment variables.
These variables will be used for connection to JSON-RPC endpoint, deployment and use of your [`RequestResponseConsumer` smart contract](contracts/RequestResponseConsumer.sol).

```shell
cp .env.example .env
```

`PROVIDER` can be set to any JSON-RPC endpoint.
The list of free available JSON-RPC endpoint can be found in [official Klaytn documentation](https://docs.klaytn.foundation/content/dapp/rpc-service/public-en#testnet-baobab-public-json-rpc-endpoints).

This repository supports connection to wallet either through mnemonic or private key.

### Mnemonic

`MNEMONIC` can be generated using [npm mnemonics package](https://www.npmjs.com/package/mnemonics).

```shell
npx mnemonics
```

After mnemonic is generated, store it in `MNEMONIC` variable inside of .env file.

Now you need to convert it to public address and fund it with KLAY.
If you do not have any KLAY in your account, you cannot deploy smart contracts or make any transactions.

You can convert your newly generated mnemonic with following hardhat task.

Please replace the `MNENONIC` with your mnemonic and run the command below.

```shell
npx hardhat address --mnemonic ${MNEMONIC}
```

The script will print out a public address corresponding to your mnemonic.
Then, you can use this address to receive free KLAY using [Baobab's faucet](https://baobab.wallet.klaytn.foundation/faucet).

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
npx hardhat deploy --network baobab
```

## Create and fund account

There are two types of payments supported by Orakle Network Request-Response: **Prepayment** and **Direct Payment**.

**Prepayment** requires user to create account and fund it with KLAY before being able to use it.
The script below will create a new account and deposit 1 KLAY from address corresponding to your mnemonic from `.env` file.

If you prefer to use Orakl Network Request-Response without having a long-lasting account, you can use **Direct Payment** method.
In such case, you can skip the following command and go directly to **Request data with Direct Payment**.

```shell
npx hardhat run scripts/create-and-fund-account.ts --network baobab
```

After successfully executing the command above, set the value of environment variable `ACC_ID` inside of `.env` file to account ID that was generated using the script above.
If you do not do it, the Request-Response using Prepayment won't be working properly.
After setting the `ACC_ID` in `.env` file, you can move to the next step **Request data with Prepayment**.

## Request data & Read response

Before running following scripts, one must deploy `RequestResponseConsumer` smart contract.
To deploy `RequestResponseConsumer`, run `npx hardhat deploy --network baobab`.

### Request data with Prepayment

```shell
npx hardhat run scripts/request-data.ts --network baobab
```

### Request data with Direct Payment

```shell
npx hardhat run scripts/request-data-direct.ts --network baobab
```

### Read response

```shell
npx hardhat run scripts/read-response.ts --network baobab
```

## Hardhat Tasks

The following tasks allow for more finer control over experimentation with the example code in this repository.

### Create a new account

```shell
npx hardhat createAccount --network baobab
```

### Deposit to an account

After you have created an account, you can deposit $KLAY to it anytime using the command below.

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
Then, the consumer contract will be able to request for Request-Responce service.

```shell
npx hardhat addConsumer \
    --consumer $CONSUMERADDRESS \
    --account-id $ACCOUNT \
    --network $NETWORK
```

### Remove a consumer

Remove a consumer contract from an account.
Then, the consumer contract will not be able to request for Request-Responce service anymore.

```shell
npx hardhat removeConsumer \
    --consumer ${CONSUMERADDRESS} \
    --account-id ${ACCOUNT} \
    --network ${NETWORK}
```
