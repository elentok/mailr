nodemailer = require 'nodemailer'

module.exports = class SmtpClient
  constructor: (@config) ->
    @transport = null

  getConnectArgs: (accountName, callback) ->
    account = @config.accounts[accountName]
    @config.getPassword accountName, 'smtp', (err, password) =>
      if err?
        callback?(err, null)
      else
        callback?(null, @_buildConnectArgs(account, password))

  _buildConnectArgs: (account, password) ->
    {
      service: account.getService()
      auth:
        user: account.getUsername()
        pass: password
    }

  connect: (accountName, callback) ->
    @getConnectArgs accountName, (err, connectArgs) =>
      if err?
        callback?(err)
      else
        @transport = nodemailer.createTransport('SMTP', connectArgs)
        callback?(null)

  send: (message, callback) ->
    @transport.sendMail(message, callback)

  close: ->
    @transport.close()

