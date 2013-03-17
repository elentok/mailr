keychainSync = require 'keychain-sync'

exports.get = (account, key) ->
  keychainSync.getPassword(account, key)

exports.set = (account, key, password) ->
  keychainSync.setPassword(account, key, password)
