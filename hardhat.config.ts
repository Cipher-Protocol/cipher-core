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

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.20",
        settings: {
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
};

export default config;
