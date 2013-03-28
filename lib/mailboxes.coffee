config = require './config/config'
ImapClient = require './clients/imap_client'
Q = require 'q'
path = require 'path'
fs = require 'fs'

exports.getMailboxes = (options) ->
  account = config.accounts[options.account]
  client = null

  connect = (settings) ->
    client = new ImapClient()
    console.log "Connecting..." if options.verbose
    client.connect(settings)

  getMailboxes = ->
    console.log "Getting mailboxes..." if options.verbose
    client.getMailboxesRecursive()

  saveMailboxesAsJSON = (mailboxes) ->
    filePath = path.join(account.getDataPath(), 'mailboxes.json')
    fs.writeFileSync(filePath, JSON.stringify(mailboxes, null, 2))
    mailboxes

  addMailboxes = (mailboxes, lines, indent = '') ->
    mailboxes.forEach (mailbox) ->
      line = indent + mailbox.name
      if mailbox.type? and mailbox.type != 'Normal'
        line += " {#{mailbox.type}}"
      lines.push(line)
      if mailbox.children? and mailbox.children.length > 0
        addMailboxes(mailbox.children, lines, indent + '  ')


  saveMailboxes = (mailboxes) ->
    filePath = path.join(account.getDataPath(), 'mailboxes')
    lines = []
    addMailboxes(mailboxes, lines)
    fs.writeFileSync(filePath, lines.join('\n'))
    mailboxes

  account.getImapSettings() \
    .then(connect).then(getMailboxes) \
    .then(saveMailboxes) \
    .then(saveMailboxesAsJSON) \
    .finally(-> client.close())

#exports.getMailboxesFile = (accountName) ->
