config = require './config/config'
SmtpClient = require './clients/smtp_client'
MessageParser = require './message_parser'
path = require 'path'
fs = require 'fs'
_ = require 'lodash'

config.load()

module.exports = class Mailr
  getContacts: (accountName, callback) ->
    account = config.accounts[accountName]
    account.getPassword('smtp').then (password) =>
      auth =
        email: account.getUsername()
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


