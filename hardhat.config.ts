import { HardhatUserConfig, task } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers";
import "dotenv/config";
import "hardhat-contract-sizer";
import "hardhat-docgen";
import "hardhat-spdx-license-identifier";
import "hardhat-storage-layout";
import "hardhat-tracer";
import "hardhat-gas-reporter";
import "solidity-coverage";
import "tsconfig-paths/register";
import { getString } from "./utils/helper";

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.20",
        settings: {
          // viaIR: true,
          optimizer: {
            enabled: true,
            runs: 200,
          },
          outputSelection: {
            "*": {
              "*": ["storageLayout"],
            },
          },
        },
      },
    ],
  },
  spdxLicenseIdentifier: {
    runOnCompile: false,
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
    strict: true,
  },
  gasReporter: {
    enabled: true,
    currency: "USD",
    gasPrice: 20,
    noColors: true,
  },
  networks: {
    goerli: {
      url: getString(process.env.GOERLI_RPC_URL),
      accounts: [getString(process.env.GOERLI_DEPLOYER_PRIVATE_KEY)],
    },
  },
};

export default config;
