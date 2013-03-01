commander = require 'commander'
keychain = require 'keychain'

module.exports = class MacPasswordStore
  getPassword: (key, callback) ->
    options =
      account: 'mailr'
      service: key
    keychain.getPassword options, (err, password) =>
      if err?
        @_askUserForPassword key, callback
      else
        callback(null, password)

  _askUserForPassword: (key, callback) ->
    commander.password "Enter password for #{key}: ", (password) =>
      if password?
        @_savePassword key, password, (err) ->
          callback(err, password)
      else
        callback('user aborted', null)

  _savePassword: (key, password, callback) ->
    options =
      account: 'mailr'
      service: key
      password: password

    keychain.setPassword(options, callback)
