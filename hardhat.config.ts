import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";
import { deployContract, expandDecimals } from "./scripts/deployTool";
import { TokenERC20, SafeMint, SafeMintAudit } from "./typechain";

dotenv.config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});


task("deploy", "deploy contract")
  .setAction(
    async ({ }, { ethers, run, network }) => {
      await run("compile");
      const [deployer, user, otherUser, auditor, arbitrator, challenger] = await ethers.getSigners();

      const token = await deployContract(
        "TokenERC20",
        network.name,
        ethers.getContractFactory,
        deployer,
        ["SafeMint Governance Token",
          "SGT",
          expandDecimals(100000000)]
      ) as TokenERC20;

      const safemint = await deployContract(
        "SafeMint",
        network.name,
        ethers.getContractFactory,
        deployer,
        [token.address]
      ) as SafeMint;
      const audit = await deployContract(
        "SafeMintAudit",
        network.name,
        ethers.getContractFactory,
        deployer,
        [token.address, safemint.address]
      ) as SafeMintAudit;
      await token.transfer(user.address, expandDecimals(10000000));
      const AUDITOR_ROLE = await safemint.AUDITOR_ROLE();
      await safemint.grantRole(AUDITOR_ROLE, audit.address);
      const ARBITRATOR_ROLE = await audit.ARBITRATOR_ROLE();
      await audit.grantRole(ARBITRATOR_ROLE, arbitrator.address);
    }
  );

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.11",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      outputSelection: {
        "*": {
          "*": [
            "abi",
            "evm.bytecode",
            "evm.deployedBytecode",
            "evm.methodIdentifiers",
            "metadata",
            "storageLayout"
          ],
          "": [
            "ast"
          ]
        }
      }
    },
  },
  networks: {
    rinkeby: {
      url: process.env.RINKEBY_URL || "",
      accounts: {
        mnemonic: process.env.MNEMONIC
      }
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};

export default config;
