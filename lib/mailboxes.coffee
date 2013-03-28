config = require './config/config'
ImapClient = require './clients/imap_client'
Q = require 'q'

exports.getMailboxes = (options) ->
  client = null

  connect = (settings) ->
    client = new ImapClient()
    console.log "Connecting..." if options.verbose
    client.connect(settings)

  getMailboxes = ->
    console.log "Getting mailboxes..." if options.verbose
    client.getMailboxesRecursive()

  config.accounts[options.account].getImapSettings() \
    .then(connect).then(getMailboxes).finally(-> client.close())
