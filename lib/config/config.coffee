path = require 'path'
fs = require 'fs'
Account = require './account'

defaultConfigDir = path.join(process.env['HOME'], '.mailr')

module.exports = class Config
  constructor: (options = {}) ->
    @path = options.path or defaultConfigDir
    @_passwordStore = options.passwordStore
    @accounts = {}

  load: ->
    unless fs.existsSync(@path)
      fs.mkdirSync(@path)
    filePath = path.resolve(path.join(@path, 'config.coffee'))
    if fs.existsSync(filePath)
      data = require filePath
      for own key, value of data
        @[key] = value
      for own key, attribs of data.accounts
        data.accounts[key] = new Account(attribs)

  getPassword: (accountName, protocol, callback) ->
    account = @accounts[accountName]
    if account.attribs.username?
      @_passwordStore.getPassword(accountName, callback)
    else
      @_passwordStore.getPassword("#{accountName}:#{protocol}", callback)

  findAccountByEmail: (email) ->
    for own accountName, account of @accounts
      if account.getEmail() == email
        return accountName
    return null
    
  getFromAddresses: ->
    addresses = []
    for own accountName, account of @accounts
      addresses.push account.getAddress()

    addresses


