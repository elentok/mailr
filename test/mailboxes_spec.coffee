require './spec_helper'

fs =
  writeFileSync: ->

config =
  currentPath: ''
  accounts:
    myAccount:
      getDataPath: -> 'account-data-path'
      getImapSettings: -> Q.when('the-settings')

class ImapClient
  connect: -> Q.when('123')
  getMailboxesRecursive: -> Q.when([{}])
  close: ->

mailboxes = sandbox.require '../lib/mailboxes',
  requires:
    './config/config': config
    './clients/imap_client': ImapClient
    fs: fs

describe "lib/mailboxes", ->
  describe "#getMailboxes", ->
    beforeEach ->
      @mailboxes = [{
        name: 'one'
        children: [{
          name: 'bla'
          type: 'special'
        }]
      }, {
        name: 'two'
      }]

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

    it "saves the mailboxes to {account-data-path}/mailboxes.json", ->
      @stub(fs, 'writeFileSync')
      @stub(ImapClient.prototype, 'getMailboxesRecursive').returns(Q.when(@mailboxes))
      mailboxes.getMailboxes(account: 'myAccount').then =>
        fs.writeFileSync.should.have.been.calledWith(
          'account-data-path/mailboxes.json', JSON.stringify(@mailboxes, null, 2))

    it "saves the mailboxes to {account-data-path}/mailboxes", ->
      mailboxesText = "one\n  bla {special}\ntwo"
      @stub(fs, 'writeFileSync')
      @stub(ImapClient.prototype, 'getMailboxesRecursive').returns(Q.when(@mailboxes))
      mailboxes.getMailboxes(account: 'myAccount').then =>
        fs.writeFileSync.should.have.been.calledWith(
          'account-data-path/mailboxes', mailboxesText)



