require './spec_helper'

class FakeConfig
  constructor: ->
    @accounts =
      myAccount:
        service: 'Gmail'
        username: 'bob'
  getPassword: (account, protocol, callback) -> callback(null, '1234')
  load: ->

class FakeSmtpClient
  connect: ->
  close: ->

Mailr = sandbox.require '../lib/mailr',
  requires:
    './config/config': FakeConfig
    './clients/smtp_client': FakeSmtpClient


describe "Mailr", ->
  describe "#send", ->
    it "sends an email", ->
      mailr = new Mailr()
      connect = FakeSmtpClient.prototype.connect = sinon.stub().callsArgWith(1, null)
      send = FakeSmtpClient.prototype.send = sinon.stub().callsArgWith(1, null, 'the-response')
      mailr.send(filename: 'test/fixtures/message1.email', account: 'myAccount')
      expect(connect).to.have.been.calledWith('myAccount')
      expect(send).to.have.been.called
      from = send.getCall(0).args[0].from
      expect(from).to.equal 'Me <me@me.com>'





