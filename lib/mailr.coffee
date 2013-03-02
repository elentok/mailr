MacPasswordStore = require './config/mac_password_store'
Config = require './config/config'
SmtpClient = require './clients/smtp_client'
MessageParser = require './message_parser'

module.exports = class Mailr
  constructor: ->
    passwordStore = new MacPasswordStore()
    @config = new Config(passwordStore: passwordStore)
    @config.load()
    @parser = new MessageParser()

  send: (options = {}, callback)->
    message = @parser.parse(options.filename)
    smtpClient = new SmtpClient(@config)
    smtpClient.connect options.account, (err) ->
      smtpClient.send message, (err, response) ->
        smtpClient.close()
        callback?(err, response)

