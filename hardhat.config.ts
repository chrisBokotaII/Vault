import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  gasReporter: {
    enabled: true,
    currency: "USD",
    coinmarketcap: "api key from coinmarket",
    outputFile: "gas-report.txt",
    reportPureAndViewMethods: true,
    showUncalledMethods: true,
    noColors: false,
    currencyDisplayPrecision: 2,
    L1: "ethereum",
    baseFee: 9,
  },
};

export default config;
