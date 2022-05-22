const hre = require("hardhat");

async function main() {
  await hre.run('compile');

  const [, ...accounts] = await hre.ethers.getSigners();

  const AddressArray = await hre.ethers.getContractFactory("AddressArray");
  const library = await AddressArray.deploy();

  console.log("AddressArray library has been deployed to:", library.address);

  const Ticket = await hre.ethers.getContractFactory("Ticket_v1", {
    libraries: {
      AddressArray: library.address
    }
  });
  const ticket = await Ticket.deploy();

  console.log("Ticket (v1) contract has been deployed to:", ticket.address);

  const Factory = await hre.ethers.getContractFactory("TicketFactory");
  const factory = await Factory.deploy(ticket.address);

  console.log("Ticket Factory contract has been deployed to:", factory.address);

  await factory.create();
  const address = await factory.getProxyAddress(0);
  const proxy = await hre.ethers.getContractAt("TicketProxy", address);

  console.log("First Ticket Proxy has been deployed to:", proxy.address);

  const implementation = await hre.ethers.getContractAt("Ticket_v1", proxy.address);
  await implementation.init();

  const timeout = new Promise(resolve => setTimeout(resolve, 30 * 1000));

  for (let index = 0; index < accounts.length; index++) {
    await implementation.connect(accounts[index]).buyTicket({
      value: hre.ethers.utils.parseEther("0.001")
    });
  }

  const players = await implementation.getPlayers();

  console.log(`${players.length} players has entered the lottery.`);

  let balance = await implementation.getWinningPrice();
  console.log(`Current winning price is`, balance.toString(), 'wei');

  await implementation.pickSurpriseWinner();
  console.log(`A surprise winner has been chosen.`);

  balance = await implementation.getWinningPrice();
  console.log(`The new winner price is`, balance.toString(), 'wei');

  console.log('Waiting for lottery to finish. This will take around 30sec...');
  await timeout;
  await implementation.pickWinner();
  console.log(`A surprise winner has been chosen.`);

  balance = await implementation.getWinningPrice();
  console.log(`The new winner price is`, balance.toString(), 'wei');
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
