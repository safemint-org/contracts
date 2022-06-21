import { expect } from "chai";
import { ethers, waffle } from "hardhat";
import { utils, BigNumber, ContractTransaction, BytesLike } from "ethers";
import { TokenERC20, SafeMint, SafeMintAudit } from "../typechain";
const [wallet, user, otherUser, auditor, arbitrator, challenger] = waffle.provider.getWallets();

const expandDecimals = (amount: any, decimals = 18): BigNumber => {
  return utils.parseUnits(String(amount), decimals);
}

describe("SafeMint", function () {
  let safemint: SafeMint;
  let token: TokenERC20;
  let audit: SafeMintAudit;
  const projectPrice = expandDecimals(100);
  const auditPrice = expandDecimals(10);
  const challengePrice = expandDecimals(10);
  const name = "测试项目";
  const projectContract = "0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D";
  const startTime = Math.floor(Date.now() / 1000) + 3600 * 24;
  const endTime = Math.floor(Date.now() / 1000) + 3600 * 24 * 2;
  const ipfsAddress = "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/1";
  let receipt: ContractTransaction;
  let AUDITOR_ROLE: BytesLike;
  let ARBITRATOR_ROLE: BytesLike;
  const comments = "comments";
  before("部署合约", async function () {
    token = await (await (await ethers.getContractFactory("TokenERC20")).deploy(
      "SafeMint Governance Token",
      "SGT",
      expandDecimals(100000000))).deployed() as TokenERC20;

    safemint = await (
      await (
        await ethers.getContractFactory("SafeMint"))
        .deploy(token.address))
      .deployed() as SafeMint;
    audit = await (
      await (
        await ethers.getContractFactory("SafeMintAudit"))
        .deploy(token.address, safemint.address))
      .deployed() as SafeMintAudit;
    await safemint.adminSetProjectPrice(projectPrice);
    await token.transfer(user.address, expandDecimals(10000000));
    AUDITOR_ROLE = await safemint.AUDITOR_ROLE();
    await safemint.grantRole(AUDITOR_ROLE, audit.address);
    await audit.adminSetAuditPrice(auditPrice);
    await audit.adminSetChellengePrice(challengePrice);
    ARBITRATOR_ROLE = await audit.ARBITRATOR_ROLE();
    await audit.grantRole(ARBITRATOR_ROLE, arbitrator.address);
  });
  it("projectPrice", async function () {
    expect(await safemint.projectPrice()).to.eq(projectPrice);
  });
  describe("核心合约", function () {
    it("ERC20:insufficient allowance", async function () {
      await expect(
        safemint.connect(user).saveProject(
          name,
          projectContract,
          startTime,
          endTime,
          ipfsAddress)
      ).to.be.revertedWith("ERC20: insufficient allowance");
    });
    it("ERC20:Approve", async function () {
      await token.connect(user).approve(safemint.address, projectPrice);
    });
    it("safeProject()", async function () {
      receipt = await safemint.connect(user).saveProject(
        name,
        projectContract,
        startTime,
        endTime,
        ipfsAddress
      );
    });
    it("event", async function () {
      await expect(receipt
      ).to.emit(safemint, "SaveProject")
        .withArgs(
          name,
          user.address,
          projectContract,
          startTime,
          endTime,
          ipfsAddress,
          projectPrice,
          1
        );
    });
    it("ERC20:Balance", async function () {
      expect(await token.allowance(user.address, safemint.address)).to.eq(0);
      expect(await token.balanceOf(safemint.address)).to.eq(projectPrice);
    });

    it("user aleardy saved", async function () {
      await token.connect(user).approve(safemint.address, projectPrice);
      await expect(
        safemint.connect(user).saveProject(
          "new project",
          projectContract,
          startTime,
          endTime,
          ipfsAddress)
      ).to.be.revertedWith("user aleardy saved");
    });

    it("contractAddress aleardy saved", async function () {
      await token.transfer(otherUser.address, projectPrice)
      await token.connect(otherUser).approve(safemint.address, projectPrice);
      await expect(
        safemint.connect(otherUser).saveProject(
          "new project",
          projectContract,
          startTime,
          endTime,
          ipfsAddress)
      ).to.be.revertedWith("contractAddress aleardy saved");
      await token.connect(otherUser).transfer(wallet.address, projectPrice)
    });

    it("name aleardy used", async function () {
      await token.transfer(otherUser.address, projectPrice)
      await token.connect(otherUser).approve(safemint.address, projectPrice);
      await expect(
        safemint.connect(otherUser).saveProject(
          name,
          user.address,
          startTime,
          endTime,
          ipfsAddress)
      ).to.be.revertedWith("name aleardy used");
      await token.connect(otherUser).transfer(wallet.address, projectPrice)
    });
    it("getProjectById", async function () {
      const project = await safemint.getProjectById(1);
      expect(project.name).to.eq(name);
      expect(project.owner).to.eq(user.address);
      expect(project.projectContract).to.eq(projectContract);
      expect(project.startTime).to.eq(BigNumber.from(startTime));
      expect(project.endTime).to.eq(BigNumber.from(endTime));
      expect(project.ipfsAddress).to.eq(ipfsAddress);
      expect(project.projectFee).to.eq(projectPrice);
      expect(project.status).to.eq(0);
    });
    it("getPending", async function () {
      const projects = await safemint.getPending(0, 100);
      expect(projects[0].name).to.eq(name);
      expect(projects[0].owner).to.eq(user.address);
      expect(projects[0].projectContract).to.eq(projectContract);
      expect(projects[0].startTime).to.eq(BigNumber.from(startTime));
      expect(projects[0].endTime).to.eq(BigNumber.from(endTime));
      expect(projects[0].ipfsAddress).to.eq(ipfsAddress);
      expect(projects[0].projectFee).to.eq(projectPrice);
      expect(projects[0].status).to.eq(0);
    });
    it("projectId", async function () {
      const projectId = await safemint.projectId(name);
      expect(projectId).to.eq(1);
      await expect(safemint.projectId('new project')).to.be.revertedWith(
        "project not exist"
      );
    });
    it("getProject", async function () {
      const project = await safemint.getProject(name);
      expect(project[0]).to.eq(1);
      expect(project[1].name).to.eq(name);
      expect(project[1].owner).to.eq(user.address);
      expect(project[1].projectContract).to.eq(projectContract);
      expect(project[1].startTime).to.eq(BigNumber.from(startTime));
      expect(project[1].endTime).to.eq(BigNumber.from(endTime));
      expect(project[1].ipfsAddress).to.eq(ipfsAddress);
      expect(project[1].projectFee).to.eq(projectPrice);
      expect(project[1].status).to.eq(0);
      await expect(safemint.getProject('new project')).to.be.revertedWith(
        "project not exist"
      );
    });
    it("getArr", async function () {
      expect(await safemint.getPassed(0, 100)).to.empty;
      expect(await safemint.getReject(0, 100)).to.empty;
      expect(await safemint.getLocked(0, 100)).to.empty;
      expect(await safemint.getChallenge(0, 100)).to.empty;
    });
    it("caller is not project owner", async function () {
      await expect(
        safemint.connect(otherUser).editProject(
          name,
          startTime,
          endTime,
          ipfsAddress)
      ).to.be.revertedWith("caller is not project owner");
    });
    it("Status error!", async function () {
      await expect(
        safemint.connect(user).editProject(
          name,
          startTime,
          endTime,
          ipfsAddress)
      ).to.be.revertedWith("Status error!");
    });
  });
  describe("审计合约", function () {
    it("sender doesn't have auditor role", async function () {
      await expect(
        audit.connect(auditor).audit(
          name,
          "comments",
          1)
      ).to.be.revertedWith("sender doesn't have auditor role");
    });
    it("grantRole", async function () {
      await audit.grantRole(AUDITOR_ROLE, auditor.address);
    });
    it("Status error!", async function () {
      await expect(audit.connect(auditor).audit(name, comments, 0))
        .to.be.revertedWith("Status error!");
      await expect(audit.connect(auditor).audit(name, comments, 3))
        .to.be.revertedWith("Status error!");
    });
    it("project not exist", async function () {
      await expect(audit.connect(auditor).audit("name", comments, 1))
        .to.be.revertedWith("project not exist");
    });
    it("audit", async function () {
      await token.transfer(auditor.address, auditPrice)
      await token.connect(auditor).approve(audit.address, auditPrice);
      let receipt = await audit.connect(auditor).audit(name, comments, 2);
      await expect(receipt
      ).to.emit(audit, "AuditProject")
        .withArgs(
          name,
          auditor.address,
          auditPrice,
          comments,
          2
        );
    });
    it("feeRecord", async function () {
      const feeRecord = await audit.feeRecord(1);
      expect(feeRecord.auditor).to.eq(auditor.address);
      expect(feeRecord.value).to.eq(auditPrice);
    });
    it("challenge Status error!", async function () {
      await token.transfer(challenger.address, challengePrice)
      await token.connect(challenger).approve(audit.address, challengePrice);
      await expect(audit.connect(challenger).challenge(name, comments))
        .to.be.revertedWith("ProjectStatusError(2)");
      await token.connect(challenger).transfer(wallet.address, challengePrice)
    });
    it("arbitrate Project status error!", async function () {
      await expect(audit.connect(arbitrator).arbitrate(name, 1))
        .to.be.revertedWith("Project status error!");
    });
    it("Project status error!", async function () {
      await expect(audit.connect(auditor).audit(name, comments, 1))
        .to.be.revertedWith("Project status error!");
    });
    it("getProject reject", async function () {
      const project = await safemint.getProject(name);
      expect(project[1].status).to.eq(2);
    });
    it("getReject", async function () {
      const projects = await safemint.getReject(0, 100);
      expect(projects[0].name).to.eq(name);
      expect(projects[0].owner).to.eq(user.address);
      expect(projects[0].projectContract).to.eq(projectContract);
      expect(projects[0].startTime).to.eq(BigNumber.from(startTime));
      expect(projects[0].endTime).to.eq(BigNumber.from(endTime));
      expect(projects[0].ipfsAddress).to.eq(ipfsAddress);
      expect(projects[0].projectFee).to.eq(projectPrice);
      expect(projects[0].status).to.eq(2);
    });
    it("getArr", async function () {
      expect(await safemint.getPassed(0, 100)).to.empty;
      expect(await safemint.getPending(0, 100)).to.empty;
      expect(await safemint.getLocked(0, 100)).to.empty;
      expect(await safemint.getChallenge(0, 100)).to.empty;
    });
    it("editProject", async function () {
      let receipt = await safemint.connect(user).editProject(
        name,
        startTime,
        endTime,
        ipfsAddress);
      await expect(receipt
      ).to.emit(safemint, "EditProject")
        .withArgs(
          name,
          startTime,
          endTime,
          ipfsAddress
        );
    });
    it("getProject pending", async function () {
      const project = await safemint.getProject(name);
      expect(project[1].status).to.eq(0);
    });
    it("getPending", async function () {
      const projects = await safemint.getPending(0, 100);
      expect(projects[0].name).to.eq(name);
      expect(projects[0].owner).to.eq(user.address);
      expect(projects[0].projectContract).to.eq(projectContract);
      expect(projects[0].startTime).to.eq(BigNumber.from(startTime));
      expect(projects[0].endTime).to.eq(BigNumber.from(endTime));
      expect(projects[0].ipfsAddress).to.eq(ipfsAddress);
      expect(projects[0].projectFee).to.eq(projectPrice);
      expect(projects[0].status).to.eq(0);
    });
    it("audit", async function () {
      await token.transfer(auditor.address, auditPrice)
      await token.connect(auditor).approve(audit.address, auditPrice);
      let receipt = await audit.connect(auditor).audit(name, comments, 1);
      await expect(receipt
      ).to.emit(audit, "AuditProject")
        .withArgs(
          name,
          auditor.address,
          auditPrice,
          comments,
          1
        );
    });
    it("getProject passed", async function () {
      const project = await safemint.getProject(name);
      expect(project[1].status).to.eq(1);
    });
    it("getPassed", async function () {
      const projects = await safemint.getPassed(0, 100);
      expect(projects[0].name).to.eq(name);
      expect(projects[0].owner).to.eq(user.address);
      expect(projects[0].projectContract).to.eq(projectContract);
      expect(projects[0].startTime).to.eq(BigNumber.from(startTime));
      expect(projects[0].endTime).to.eq(BigNumber.from(endTime));
      expect(projects[0].ipfsAddress).to.eq(ipfsAddress);
      expect(projects[0].projectFee).to.eq(projectPrice);
      expect(projects[0].status).to.eq(1);
    });
    it("challenge", async function () {
      await token.transfer(challenger.address, challengePrice)
      await token.connect(challenger).approve(audit.address, challengePrice);
      let receipt = await audit.connect(challenger).challenge(name, comments);
      await expect(receipt
      ).to.emit(audit, "ChallengeProject")
        .withArgs(
          name,
          challenger.address,
          challengePrice,
          comments
        );
    });
    it("editProject Status error!", async function () {
      await expect(
        safemint.connect(user).editProject(
          name,
          startTime,
          endTime,
          ipfsAddress)
      ).to.be.revertedWith("Status error!");
    });
    it("auditor Project status error!", async function () {
      await expect(audit.connect(auditor).audit(name, comments, 1))
        .to.be.revertedWith("Project status error!");
    });
    it("challenge Status error!", async function () {
      await token.transfer(challenger.address, challengePrice)
      await token.connect(challenger).approve(audit.address, challengePrice);
      await expect(audit.connect(challenger).challenge(name, comments))
        .to.be.revertedWith("Status error!");
    });
    it("arbitrate", async function () {
      let receipt = await audit.connect(arbitrator).arbitrate(name, 1);
      await expect(receipt
      ).to.emit(audit, "ArbitrateProject")
        .withArgs(
          name,
          arbitrator.address, 1
          );
    });
    it("claimAuditReward", async function () {
      let receipt = await audit.connect(auditor).claimAuditReward(name);
      await expect(receipt
      ).to.emit(token, "Transfer")
        .withArgs(
          audit.address,
          auditor.address,
          expandDecimals(120)
          );
    });
  });
});
