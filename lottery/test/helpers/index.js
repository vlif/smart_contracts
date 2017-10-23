const NULL_ADDRESS = ['0x0000000000000000000000000000000000000000', '0x']

module.exports = {
  isNull: function (address) {
    return NULL_ADDRESS.includes(address)
  }
}
