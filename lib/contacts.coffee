Q = require 'q'
config = require './config/config'
path = require 'path'
fs = require 'fs'
_ = require 'lodash'

GoogleContacts = require 'gcontacts'

exports.getContacts = (accountName) ->
  config.accounts[accountName].getContactsSettings().then (settings) ->
    gcontacts = new GoogleContacts()
    gcontacts.connect(settings).then ->
      gcontacts.getContacts().then (page) ->
        page.contacts

exports.getContactsFile = (accountName) ->
  contactsPath = path.join(config.currentPath, 'contacts')
  fs.mkdirSync(contactsPath) unless fs.existsSync(contactsPath)
  path.join(contactsPath, "#{accountName}.contacts")

exports.updateContacts = (accountName) ->
  @getContacts(accountName).then (contacts) =>
    contacts = _.map contacts, (c) => @formatContact(c)
    filePath = @getContactsFile(accountName)
    fs.writeFileSync filePath, contacts.join('\n')

exports.formatContact = (contact) ->
  if contact.name? and contact.name.length > 0
    "#{contact.name} <#{contact.email}>"
  else
    contact.email

