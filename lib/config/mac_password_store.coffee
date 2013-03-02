commander = require 'commander'
keychainSync = require 'keychain-sync'

module.exports = class MacPasswordStore
  getPassword: (key, callback) ->
    password = keychainSync.getPassword('mailr', key)
    if password?
      callback?(null, password)
    else
      @_askUserForPassword key, callback

  _askUserForPassword: (key, callback) ->
    commander.password "Enter password for #{key}: ", (password) =>
      if password?
        keychainSync.setPassword('mailr', key, password)
        callback?(null, password)
      else
        callback?('user aborted', null)
