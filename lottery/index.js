require('dotenv').config()
const { spawn } = require('child_process')
const kue = require('kue')

const BASE_PATH = './build/contracts'

const queue = kue.createQueue({ redis: process.env.REDIS_HOST })

module.exports = function(callback) {
  console.log(`Deployer started with REDIS_HOST=${process.env.REDIS_HOST} TRUFFLE_NETWORK=${process.env.TRUFFLE_NETWORK}`)
  queue.process('contracts:deploy', deploy)

  function getArtifacts () {
    return {
      RegularRaffle: require(`${BASE_PATH}/RegularRaffle.json`),
      FinalRaffle: require(`${BASE_PATH}/FinalRaffle.json`),
      RaffleOwner: require(`${BASE_PATH}/RaffleOwner.json`),
      TicketSales: require(`${BASE_PATH}/TicketSales.json`),
      Ticket: require(`${BASE_PATH}/Ticket.json`),
      FinalFund: require(`${BASE_PATH}/Fund.json`),
      RegularFund: require(`${BASE_PATH}/Fund.json`),
    }
  }

  async function compile () {
    console.log('truffle compile')
    return new Promise((resolve, reject) => {
      spawn('truffle', ['compile', '--network', process.env.TRUFFLE_NETWORK])
        .on('close', (code) => (code === 0 ? resolve() : reject()))
      }
    )
  }

  async function deploy (job, done) {
    let rawData = ''
    await compile()
    console.log('truffle migrate')
    spawn('truffle', ['migrate', '--network', process.env.TRUFFLE_NETWORK]).stdout
      .on('data', (data) => (rawData += data))
      .on('close', (code) => createJob(code, rawData, done))
  }

  function createJob (code, rawData, done) {
    const artifacts = getArtifacts()
    const contractNames = [
      'Ticket',
      'RegularFund',
      'FinalFund',
      'TicketSales',
      'RaffleOwner',
      'RegularRaffle',
      'FinalRaffle'
    ]

    console.log(rawData)

    let contracts = {}

    contractNames.forEach((contractName) => {
      contracts[contractName] = {
        address: ['RegularRaffle', 'FinalRaffle'].includes(contractName) ? null : mathAddress(contractName, rawData).trim(),
        artifact: artifacts[contractName],
      }
    })

    console.log('contracts:deployed')
    queue.createJob('contracts:deployed', { contracts }).save()
    done()
  }

  function mathAddress (contractName, rawData) {
    return rawData.match(new RegExp(`${contractName}: (0x[a-z0-9]*)`))[1]
  }
}
