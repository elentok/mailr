require './spec_helper'

fs =
  mkdirSync: ->
  existsSync: -> true
  writeFileSync: ->

config =
  currentPath: ''
  accounts:
    myAccount:
      getImapSettings: -> Q.when('the-settings')

class ImapClient
  connect: -> Q.when('123')
  getMailboxesRecursive: -> Q.when([{}])
  close: ->

mailboxes = sandbox.require '../lib/mailboxes',
  requires:
    './config/config': config
    './clients/imap_client': ImapClient

describe "lib/mailboxes", ->
  describe "#getMailboxes", ->
    it "connects to imap", ->
      @stub(ImapClient.prototype, 'connect')
      mailboxes.getMailboxes(account: 'myAccount').then ->
        expect(ImapClient::connect).to.have.been.calledWith('the-settings')

    it "gets the mailboxes", ->
      @stub(ImapClient.prototype, 'getMailboxesRecursive').returns(Q.when([]))
      mailboxes.getMailboxes(account: 'myAccount').then ->
        expect(ImapClient::getMailboxesRecursive).to.have.been.calledOnce
    
    it "closes the connection when done", ->
      @stub(ImapClient.prototype, 'close')
      mailboxes.getMailboxes(account: 'myAccount').then ->
        ImapClient::close.should.have.been.calledOnce





