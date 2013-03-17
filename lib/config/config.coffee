path = require 'path'
fs = require 'fs'
Account = require './account'

defaultConfigDir = path.join(process.env['HOME'], '.mailr')

exports.currentPath = null

exports.accounts = {}

exports.load = (dir = defaultConfigDir) ->
  @currentPath = dir
  unless fs.existsSync(dir)
    fs.mkdirSync(dir)
  filePath = path.resolve(path.join(dir, 'config.coffee'))
  if fs.existsSync(filePath)
    data = require filePath
    for own key, value of data
      @[key] = value
    @accounts = {}
    for own key, attribs of data.accounts
      attribs.name = key
      @accounts[key] = new Account(attribs)

getEmailFromAddress = (address) ->
  match = /<(.*)>/.exec(address)
  if match?
    match[1]
  else
    address

exports.findAccountByEmail = (email) ->
  email = getEmailFromAddress(email)

  for own accountName, account of @accounts
    if account.getEmail() == email
      return account
  return null

exports.getFromAddresses = ->
  addresses = []
  for own accountName, account of @accounts
    addresses.push account.getFromAddress()
  addresses
