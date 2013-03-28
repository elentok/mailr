Q = require 'q'
inbox = require 'inbox'
_ = require 'lodash'

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

  getMailboxChildren: (mailbox) ->
    defer = Q.defer()
    mailbox.listChildren (err, children) ->
      if err?
        defer.reject(err)
      else
        defer.resolve(children)
    defer.promise

  loadMailboxesChildren: (mailboxes) ->
    promises = _.map mailboxes, (mailbox) =>
      @getMailboxChildren(mailbox).then (children) ->
        mailbox.children = children
        mailbox
    Q.all(promises)

  getMailboxesRecursive: ->
    @getMailboxes().then (mailboxes) => @loadMailboxesChildren(mailboxes)

  close: ->
    @connection.close()
