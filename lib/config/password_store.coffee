Q = require 'q'
keychain = require './mac_keychain'
commander = require 'commander'

exports.get = (key) ->
  deferred = Q.defer()
  password = keychain.get('mailr', key)
  if password?
    deferred.resolve(password)
  else
    commander.password "Enter password for #{key}: ", (password) ->
      if password? and password.length > 0
        keychain.set('mailr', key, password)
        deferred.resolve(password)
      else
        deferred.reject(new Error('user-abort'))
  deferred.promise
