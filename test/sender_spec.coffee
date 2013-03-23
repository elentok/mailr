require './spec_helper'
Q = require 'q'

config =
  accounts:
    myAccount:
      getSmtpSettings: -> Q.when('smtp-settings')
  load: ->


class SmtpClient
  connect: ->
  close: ->
  send: ->

sender = sandbox.require '../lib/sender',
  requires:
    './config/config': config
    './clients/smtp_client': SmtpClient

describe "lib/sender", ->
  beforeEach ->
    @connect = SmtpClient.prototype.connect = @stub()
    @send = SmtpClient.prototype.send = @stub().returns(Q.when('123'))
    @options =
      filename: 'test/fixtures/message1.email'
      account: 'myAccount'

  describe "#send", ->
    it "returns a promise", ->
      sender.send(@options).then.should.be.a.function

    it "sends an email", ->
      sender.send(@options).then =>
        expect(@connect).to.have.been.calledWith('smtp-settings')
        expect(@send).to.have.been.called
        from = @send.getCall(0).args[0].from
        expect(from).to.equal 'Me <me@me.com>'





