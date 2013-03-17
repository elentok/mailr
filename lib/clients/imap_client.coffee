inbox = require 'inbox'

#Config = require './config/config'

module.exports = class ImapClient
  constructor: (options) ->
    @client = inbox.createConnection false, options.server,
      secureConnection: true,
      auth:
        user: options.username,
        pass: options.password
    @client.on 'connect', => @onConnect()

  connect: (callback) ->
    console.log "Connecting..."
    @client.on 'connect', ->
      callback(null)
    @client.on 'error', (err) ->
      callback(err)
    @client.connect()

  onConnect: ->
    console.log "Connected!"
    @client.listMailboxes (err, mailboxes) ->
      console.log err
      console.log mailboxes

  getMailboxes: (callback) ->

ImapClient.getSettings = (config, accountName, callback) ->
  account = config.accounts[accountName]
  options = account.getServer('imap') or {}
  options.username = account.getUsername('imap')
  config.getPassword accountName, 'imap', (err, password) ->
    if err?
      callback(err)
    else
      options.password = password
      callback(null, options)





#passwordStore = new (require './config/mac_password_store')()
#config = new Config(passwordStore: passwordStore)
#config.load()

#config.getPassword 'gmail', 'imap', (err, password) ->
  #opts =
    #server: 'imap.gmail.com'
    #port: 993
    #username: config.accounts.gmail.getUsername()
    #password: password
  #mailbox = new Mailbox(opts)
  #mailbox.connect()
