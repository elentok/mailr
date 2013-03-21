config = require './config/config'
SmtpClient = require './clients/smtp_client'
MessageParser = require './message_parser'
path = require 'path'
fs = require 'fs'

parser = new MessageParser()

findAccount = (accountName, fromAddress) ->
  if accountName?
    config.accounts[accountName]
  else if fromAddress?
    config.findAccountByEmail(fromAddress)

exports.send = (options = {}) ->
  message = parser.parse(options.filename)
  account = findAccount(options.account, message.fromAddress)
  account.getSmtpSettings().then (settings) ->
    smtpClient = new SmtpClient()
    smtpClient.connect(settings)
    smtpClient.send(message).finally =>
      smtpClient.close()


