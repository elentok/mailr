require '../spec_helper'

inbox = {}

ImapClient = require '../../lib/clients/imap_client',
  requires:
    inbox: inbox

xdescribe "ImapClient", ->
  describe ".getSettings", ->
    it "gets the correct settings from Config", (done) ->
      config =
        accounts:
          myAccount:
            getServer: (protocol) ->
              expect(protocol).to.equal 'imap'
              { host: 'imap.gmail.com', port: 123 }
            getUsername: (protocol) ->
              expect(protocol).to.equal 'imap'
              'my-user'
        getPassword: (accountName, protocol, callback) ->
          expect(accountName).to.equal 'myAccount'
          expect(protocol).to.equal 'imap'
          callback(null, 'my-password')

      ImapClient.getSettings config, 'myAccount', (err, settings) ->
        expect(settings).to.eql {
          host: 'imap.gmail.com'
          port: 123
          username: 'my-user'
          password: 'my-password'
        }
        done()

  describe "#connect", ->
    beforeEach ->
      @settings =
        host: 'imap.gmail.com'
        port: 123
        username: 'my-user'
        password: 'my-password'
      @client = new ImapClient(@settings)

    it "creates a connection", ->


    it "calls inbox.connect", ->
      client = new ImapClient(settings)
      client.connect()


    describe "when successful", ->
      it "calls the callback with null", ->
    describe "when fails", ->
      it "calls the callback with the error", ->


