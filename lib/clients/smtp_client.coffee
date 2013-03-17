nodemailer = require 'nodemailer'
Q = require 'q'

module.exports = class SmtpClient
  constructor: () ->
    @transport = null

  getConnectArgs: (account, callback) ->
    deferred = Q.defer()
    account.getPassword('smtp')
      .then (password) =>
        args = @_buildConnectArgs(account, password)
        deferred.resolve(args)
      .fail (err) ->
        deferred.reject(err)
    deferred.promise

  _buildConnectArgs: (account, password) ->
    {
      service: account.getService()
      auth:
        user: account.getUsername()
        pass: password
    }

  connect: (account) ->
    @getConnectArgs(account).then (args) =>
      console.log "calling nodemailer.createTransport"
      @transport = nodemailer.createTransport('SMTP', args)

  send: (message, callback) ->
    @transport.sendMail(message, callback)

  close: ->
    @transport.close()

