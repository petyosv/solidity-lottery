const { expect } = require("chai");
const { ethers } = require("hardhat");

let factory, ticket, proxy, implementation, addressArray;
let accounts;

beforeEach(async () => {
  accounts = await ethers.getSigners();

  const AddressArray = await ethers.getContractFactory("AddressArray");
  addressArray = await AddressArray.deploy();

  const Ticket_v1 = await ethers.getContractFactory("Ticket_v1", {
    libraries: {
      AddressArray: addressArray.address
    }
  });
  ticket = await Ticket_v1.deploy();

  const Factory = await ethers.getContractFactory("TicketFactory");
  factory = await Factory.deploy(ticket.address);

  await factory.deploy();
  const address = await factory.getProxyAddress(0);
  proxy = await ethers.getContractAt("TicketProxy", address);

  implementation = await ethers.getContractAt("Ticket_v1", proxy.address);
  await implementation.init();

});

describe("Proxy", function () {

  it("The proxy points to an implementation contract.", async () => {
    expect(await proxy.getImplementation()).to.eq(ticket.address);
  });

  it("Test Ticket contract update.", async () => {
    expect(await implementation.connect(accounts[1]).buyTicket({
      value: ethers.utils.parseEther("0.001")
    })).to.be.ok;

    const Ticket_v2 = await ethers.getContractFactory("Ticket_v2", {
      libraries: {
        AddressArray: addressArray.address
      }
    });
    ticket = await Ticket_v2.deploy();

    await factory.updateTicket(ticket.address);

    expect(await implementation.getPlayers()).to.have.length(1);

    await expect(
      implementation.connect(accounts[2]).buyTicket({
        value: ethers.utils.parseEther("0.001")
      })
    ).to.be.revertedWith(
      "Ticket price is 0.002 ether."
    );
  });

  it("Deploy second proxy.", async () => {
    expect(await implementation.connect(accounts[1]).buyTicket({
      value: ethers.utils.parseEther("0.001")
    })).to.be.ok;

    await factory.deploy();
    const address = await factory.getProxyAddress(1);
    const proxy_2 = await ethers.getContractAt("TicketProxy", address);

    const implementation_2 = await ethers.getContractAt("Ticket_v1", proxy_2.address);
    await implementation_2.init();

    expect(await implementation.getPlayers()).to.have.length(1);
    expect(await implementation.getWinningPrice()).to.be.equal(ethers.utils.parseEther("0.001"));
    expect(await implementation_2.getPlayers()).to.have.length(0);
    expect(await implementation_2.getWinningPrice()).to.be.equal(0);
  });

});


describe("Buy a ticket", function () {

  it("The value does not match the ticket price.", async () => {
    await expect(
      implementation.buyTicket({
        value: ethers.utils.parseEther("0.002")
      })
    ).to.be.revertedWith(
      "Ticket price is 0.001 ether."
    );
  });

  it("The owner of the lottery can't buy a ticket.", async () => {
    await expect(
      implementation.buyTicket({
        value: ethers.utils.parseEther("0.001")
      })
    ).to.be.revertedWith(
      "The owner of this lottery can not by a ticket."
    );
  });

  it("User different from the owner is trying to buy a ticket.", async () => {
    expect(await implementation.getPlayers()).to.have.length(0);

    await implementation.connect(accounts[1]).buyTicket({
      value: ethers.utils.parseEther("0.001")
    });

    expect(await implementation.getPlayers()).to.have.length(1);
  });

  it("User is trying to buy ticket after the purchase time has end.", async () => {
    await ethers.provider.send("evm_increaseTime", [30]);

    await expect(
      implementation.connect(accounts[1]).buyTicket({
        value: ethers.utils.parseEther("0.001")
      })
    ).to.be.revertedWith(
      "This lottery is no longer active."
    );
  });

});

describe("Pick a surprise winner", function () {

  it("Owner is trying to pick a surprise winner with no tickets sold.", async () => {
    await expect(
      implementation.pickSurpriseWinner()
    ).to.be.revertedWith(
      "No tickets were sold."
    );
  });

  it("Owner is trying to pick a surprise winner after the purchase time has end.", async () => {
    await ethers.provider.send("evm_increaseTime", [30]);

    await expect(
      implementation.pickSurpriseWinner()
    ).to.be.revertedWith(
      "Suprise winner can be picked while the lottery is active."
    );
  });

  it("User different from owner is trying to pick a surprise winner.", async () => {
    await expect(
      implementation.connect(accounts[1]).pickSurpriseWinner()
    ).to.be.revertedWith(
      "Caller is not the owner"
    );
  });

  it("The owner is picking a surprise winner while the lottery is active (Single player).", async () => {
    await implementation.connect(accounts[1]).buyTicket({
      value: ethers.utils.parseEther("0.001")
    });

    const balance = await accounts[1].getBalance();
    await implementation.pickSurpriseWinner();

    expect(await accounts[1].getBalance()).to.be.equal(balance.add(ethers.utils.parseEther("0.0005")));
    expect(await implementation.getWinningPrice()).to.be.equal(ethers.utils.parseEther("0.0005"));
    expect(await implementation.getPlayers()).to.have.length(0);
  });

  it("The owner is picking a surprise winner while the lottery is active (Multiple players).", async () => {
    for (let i = 1; i < accounts.length; i++) {
      await implementation.connect(accounts[i]).buyTicket({
        value: ethers.utils.parseEther("0.001")
      });
    }

    expect(await implementation.getPlayers()).to.have.length(19);

    await implementation.pickSurpriseWinner();

    expect(await implementation.getWinningPrice()).to.be.equal(ethers.utils.parseEther("0.0095"));
    expect(await implementation.getPlayers()).to.have.length(18);
  });

});

describe("Pick a winner", function () {

  it("The owner is picking a winner while the lottery is active.", async () => {
    await expect(
      implementation.pickWinner()
    ).to.be.revertedWith(
      "The lottery is still active."
    );
  });

  it("Owner is trying to pick a winner with no tickets sold.", async () => {
    await ethers.provider.send("evm_increaseTime", [30]);
    await expect(
      implementation.pickWinner()
    ).to.be.revertedWith(
      "No tickets were sold."
    );
  });

  it("User different from owner is trying to pick a winner.", async () => {
    await expect(
      implementation.connect(accounts[1]).pickWinner()
    ).to.be.revertedWith(
      "Caller is not the owner"
    );
  });

  it("The owner is picking a winner after the purchase time has end (Single player).", async () => {
    await implementation.connect(accounts[1]).buyTicket({
      value: ethers.utils.parseEther("0.001")
    });

    const balance = await accounts[1].getBalance();

    await ethers.provider.send("evm_increaseTime", [30]);
    await implementation.pickWinner();

    expect(await accounts[1].getBalance()).to.be.equal(balance.add(ethers.utils.parseEther("0.001")));
    expect(await implementation.getWinningPrice()).to.be.equal(0);
  });

  it("The owner is picking a winner after the purchase time has end (Multiple players).", async () => {
    for (let i = 1; i < accounts.length; i++) {
      await implementation.connect(accounts[i]).buyTicket({
        value: ethers.utils.parseEther("0.001")
      });
    }

    await ethers.provider.send("evm_increaseTime", [30]);
    await implementation.pickWinner();

    expect(await implementation.getWinningPrice()).to.be.equal(0);
  });

});
