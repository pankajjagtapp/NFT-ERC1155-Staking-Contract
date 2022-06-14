const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('NFT Staking Contract', function () {
	let JagguToken;
	let jagguTokenContract;
	let MyNFT;
	let myNFTContract;
	let Staking;
	let stakingContract;
	let owner;
	let addr1;
	let addr2;
	let addrs;

	beforeEach(async () => {
		[owner, addr1, addr2, ...addrs] = await ethers.getSigners();
		JagguToken = await hre.ethers.getContractFactory('JagguToken');
		jagguTokenContract = await JagguToken.deploy();
		await jagguTokenContract.deployed();

		// NFT
		MyNFT = await hre.ethers.getContractFactory('MyNFT');
		myNFTContract = await MyNFT.deploy();
		await myNFTContract.deployed();

		// Staking
		Staking = await hre.ethers.getContractFactory('Staking');
		stakingContract = await Staking.deploy(
			jagguTokenContract.address,
			myNFTContract.address
		);
		await stakingContract.deployed();
	});

	describe('Deployment', () => {
		it('Should return the Correct Token Name', async () => {
			const JagguToken = await ethers.getContractFactory('JagguToken');
			const jagguTokenContract = await JagguToken.deploy();
			await jagguTokenContract.deployed();

			expect(await jagguTokenContract.name()).to.equal('JagguToken');
		});
	});

	describe('Staking Tests', () => {
		it('Should mint Jaggu token', async () => {
			await jagguTokenContract.mint(stakingContract.address, 1000000000);
			expect(
				await jagguTokenContract.balanceOf(stakingContract.address)
			).to.equal(ethers.utils.parseUnits('1000000000', 18));
		});

		it('Should stake any NFT', async () => {
			await myNFTContract.mint(addr1.address, 1, 5, 0x00);
			await myNFTContract
				.connect(addr1)
				.setApprovalForAll(stakingContract.address, true);
			await stakingContract.connect(addr1).stakeNFT(1, 5);
			const Staker = await stakingContract.stakesMapping(addr1.address);
			expect(Staker.tokenId).to.equal(1);
		});
	});
});
