Q = require 'q'
inbox = require 'inbox'

module.exports = class ImapClient
  connect: (options) ->
    defer = Q.defer()
    @connection = inbox.createConnection.apply(inbox, options)
    @connection.on 'connect', -> defer.resolve()
    @connection.on 'error', (err) -> defer.reject(err)
    @connection.connect()
    defer.promise

  getMailboxes: ->
    defer = Q.defer()
    @connection.listMailboxes (err, mailboxes) ->
      if err?
        defer.reject(err)
      else
        defer.resolve(mailboxes)
    defer.promise

