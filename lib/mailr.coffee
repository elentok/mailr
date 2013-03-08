MacPasswordStore = require './config/mac_password_store'
Config = require './config/config'
SmtpClient = require './clients/smtp_client'
MessageParser = require './message_parser'
path = require 'path'
fs = require 'fs'
_ = require 'lodash'

module.exports = class Mailr
  constructor: ->
    passwordStore = new MacPasswordStore()
    @config = new Config(passwordStore: passwordStore)
    @config.load()
    @parser = new MessageParser()

  send: (options = {}, callback)->
    message = @parser.parse(options.filename)
    if options.account?
      accountName = options.account
    else
      accountName = @config.findAccountByEmail(message.fromAddress)
    smtpClient = new SmtpClient(@config)
    smtpClient.connect accountName, (err) ->
      smtpClient.send message, (err, response) ->
        smtpClient.close()
        callback?(err, response)

  getContacts: (accountName, callback) ->
    @config.getPassword accountName, 'smtp', (err, password) =>
      auth =
        email: @config.accounts[accountName].attribs.username
        password: password
      GoogleContacts = require 'gcontacts'
      gcontacts = new GoogleContacts(auth)
      console.log "Connecting..."
      gcontacts.connect (err) ->
        if err?
          callback(err, null)
        else
          gcontacts.getContacts (err, page) ->
            if err?
              callback?(err, null)
            else
              callback?(null, page.contacts)

  updateContacts: (accountName, callback) ->
    @getContacts accountName, (err, contacts) =>
      if err?
        callback?(err, null)
      else
        filepath = @_getContactsFileForAccount(accountName)
        contacts = _.map contacts, (c) ->
          if c.name? and c.name.length > 0
            "#{c.name} <#{c.email}>"
          else
            c.email
        fs.writeFileSync(filepath, contacts.join("\n"))
        callback(null, contacts)

  _getContactsFileForAccount: (accountName) ->
    contactsPath = path.join(@config.path, 'contacts')
    fs.mkdirSync(contactsPath) unless fs.existsSync(contactsPath)
    path.join(contactsPath, "#{accountName}.contacts")


