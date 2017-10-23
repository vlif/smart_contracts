const BASE_PATH = './contracts'

const FinalRaffle = artifacts.require(`${BASE_PATH}/storages/raffles/FinalRaffle`)
const RegularRaffle = artifacts.require(`${BASE_PATH}/storages/raffles/RegularRaffle`)

const Fund = artifacts.require(`${BASE_PATH}/storages/funds/Fund`)

const Ticket = artifacts.require(`${BASE_PATH}/storages/Ticket`)

const RaffleOwner = artifacts.require(`${BASE_PATH}/Raffle/Regular/RaffleOwner`)
const TicketSales = artifacts.require(`${BASE_PATH}/TicketSales`)

module.exports = async function(deployer) {
  await deployer.deploy(Ticket)
  const ticket = Ticket.at(Ticket.address)

  await deployer.deploy(Fund)
  const regularFund = Fund.at(Fund.address)

  console.log(`RegularFund: ${Fund.address}`)

  await deployer.deploy(Fund)
  const finalFund = Fund.at(Fund.address)

  console.log(`FinalFund: ${Fund.address}`)

  await deployer.deploy(TicketSales, regularFund.address, finalFund.address, ticket.address)
  await deployer.deploy(RaffleOwner, regularFund.address, finalFund.address, ticket.address)

  const raffleOwner = RaffleOwner.at(RaffleOwner.address)

  await regularFund.addAccess(RaffleOwner.address)
  await finalFund.addAccess(RaffleOwner.address)
  await ticket.addAccess(TicketSales.address)
  await ticket.addAccess(RaffleOwner.address)

  raffleOwner.createNewRaffle()
}
