require '../spec_helper'

connection =
  connect: ->
  on: ->
  listMailboxes: ->

inbox =
  createConnection: -> connection

ImapClient = sandbox.require '../../lib/clients/imap_client',
  requires:
    inbox: inbox

describe "ImapClient", ->
  beforeEach ->
    @settings = ['the-port', 'imap.gmail.com', {
      secureConnection: true,
      auth:
        user: 'my-user'
        pass: 'my-password'
    }]
    @client = new ImapClient()

  describe "#connect(settings)", ->
    it "returns a promise", ->
      @client.connect(@settings).then.should.be.a.function

    it "creates a new inbox connection", ->
      @spy(inbox, 'createConnection')
      @client.connect(@settings)
      inbox.createConnection.should.have.been.calledOnce
      inbox.createConnection.lastCall.args.should.eql @settings

    it "calls connection.connect", ->
      @stub(connection, 'connect')
      @client.connect(@settings)
      connection.connect.should.have.been.calledOnce

    describe "when successful", ->
      it "resolves the promise", ->
        @stub(connection, 'on').withArgs('connect').callsArgWith(1, null)
        @client.connect(@settings).should.be.fulfilled

    describe "when error", ->
      it "rejects the promise", ->
        @stub(connection, 'on').withArgs('error').callsArgWith(1, 'the-error')
        @client.connect(@settings).fail (err) ->
          expect(err).to.equal 'the-error'

  describe "#getMailboxes", ->
    it "returns a promise", ->
      @client.connect(@settings)
      @client.getMailboxes().then.should.be.a.function

    it "calls connection.listMailboxes", ->
      @stub(connection, 'listMailboxes')
      @client.connect(@settings)
      @client.getMailboxes()
      connection.listMailboxes.should.have.been.calledOnce

    describe "when successful", ->
      it "resolves the promise with the mailboxes", ->
        @stub(connection, 'listMailboxes') \
          .callsArgWith(0, null, 'the-mailboxes')
        @client.connect(@settings)
        @client.getMailboxes().should.become('the-mailboxes')

    describe "when fails", ->
      it "rejects the promise with the error", ->
        @stub(connection, 'listMailboxes') \
          .callsArgWith(0, 'the-error', null)
        @client.connect(@settings)
        @client.getMailboxes().fail (err) ->
          err.should.equal 'the-error'


