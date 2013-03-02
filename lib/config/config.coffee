path = require 'path'
fs = require 'fs'

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

  getPassword: (accountName, protocol, callback) ->
    account = @accounts[accountName]
    if account.username?
      @_passwordStore.getPassword(accountName, callback)
    else
      @_passwordStore.getPassword("#{accountName}:#{protocol}", callback)

    
