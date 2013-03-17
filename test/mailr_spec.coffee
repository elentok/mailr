require './spec_helper'
Q = require 'q'

config =
  accounts:
    myAccount:
      getService: -> 'Gmail'
      getUsername: -> 'bob'
      getPassword: -> Q.when('1234')
  load: ->


class FakeSmtpClient
  connect: ->
  close: ->

Mailr = sandbox.require '../lib/mailr',
  requires:
    './config/config': config
    './clients/smtp_client': FakeSmtpClient


describe "Mailr", ->
  describe "#send", ->
    it "sends an email", (done) ->
      mailr = new Mailr()
      account = config.accounts.myAccount
      connect = FakeSmtpClient.prototype.connect =
        @stub().withArgs(account).returns(Q.when(true))
      send = FakeSmtpClient.prototype.send = @stub().callsArgWith(1, null, 'the-response')
      options =
        filename: 'test/fixtures/message1.email'
        account: 'myAccount'
      mailr.send options, ->
        expect(connect).to.have.been.calledWith(config.accounts.myAccount)
        expect(send).to.have.been.called
        from = send.getCall(0).args[0].from
        expect(from).to.equal 'Me <me@me.com>'
        done()





