nodemailer = require 'nodemailer'

module.exports = class SmtpClient
  constructor: (@config) ->
    @transport = null

  getConnectArgs: (accountName, callback) ->
    settings = @config.accounts[accountName]
    username = settings.username
    @config.getPassword accountName, 'smtp', (err, password) ->
      if err?
        callback?(err, null)
      else
        callback?(null, {
          service: settings.service
          auth:
            user: username
            pass: password
        })

  connect: (accountName, callback) ->
    @getConnectArgs accountName, (err, settings) =>
      if err?
        callback?(err)
      else
        @transport = nodemailer.createTransport('SMTP', settings)
        callback?(null)

  send: (message, callback) ->
    @transport.sendMail(message, callback)


