# Cipher Protocol Core Repository

## Get Started

You need Node.js 16+ to build. Use [nvm](https://github.com/nvm-sh/nvm) to install it.

Clone this repository, install Node.js dependencies, and build the source code:

```bash
git clone git@github.com:Cipher-Protocol/cipher-core.git
npm i
```

## Build

Build different type of the UTXO circuit and generate the solidity verifier contract
The build result will be in `build` folder

```bash
npm run build:circuit
```

Build the solidity smart contract

```bash
npm run build:contract
```

## Test

Run all the test cases:

```bash
npm run test:contract
```

## Change Configuration

Change type of the UTXO configuration in `uxto-config.json` file.
nIns: number of inputs
mOuts: number of outputs

```json
[
  { "nIns": 0, "mOuts": 1 },
  { "nIns": 0, "mOuts": 2 },
  { "nIns": 0, "mOuts": 4 },
  { "nIns": 1, "mOuts": 0 },
  { "nIns": 1, "mOuts": 1 },
  { "nIns": 1, "mOuts": 2 },
  { "nIns": 1, "mOuts": 4 },
  { "nIns": 2, "mOuts": 0 },
  { "nIns": 2, "mOuts": 1 },
  { "nIns": 2, "mOuts": 2 },
  { "nIns": 2, "mOuts": 4 },
  { "nIns": 4, "mOuts": 0 },
  { "nIns": 4, "mOuts": 1 },
  { "nIns": 4, "mOuts": 2 },
  { "nIns": 4, "mOuts": 4 }
]
```
