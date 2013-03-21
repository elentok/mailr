nodemailer = require 'nodemailer'
Q = require 'q'

module.exports = class SmtpClient
  constructor: () ->
    @transport = null

  connect: (settings) ->
    @transport = nodemailer.createTransport('SMTP', settings)

  send: (message) ->
    sendMail = Q.nbind(@transport.sendMail, @transport)
    sendMail(message)


  close: ->
    @transport.close()

