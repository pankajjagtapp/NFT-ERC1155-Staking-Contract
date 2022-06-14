const hre = require('hardhat');

async function main() {
	const JagguToken = await hre.ethers.getContractFactory('JagguToken');
	const jagguToken = await JagguToken.deploy();
	await jagguToken.deployed();

	console.log('JagguToken Contract deployed to: ', jagguToken.address);

	const MyNFT = await hre.ethers.getContractFactory('MyNFT');
	const myNFT = await MyNFT.deploy();
	await myNFT.deployed();

	console.log('MyNFT Contract deployed to: ', myNFT.address);

	const Staking = await hre.ethers.getContractFactory('Staking');
	const staking = await Staking.deploy(jagguToken.address, myNFT.address);
	await staking.deployed();

	console.log('Staking Contract deployed to:', staking.address);
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
