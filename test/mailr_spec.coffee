require './spec_helper'
Q = require 'q'

config =
  accounts:
    myAccount:
      getSmtpSettings: -> Q.when('smtp-settings')
    #myAccount:
      #getService: -> 'Gmail'
      #getUsername: -> 'bob'
      #getPassword: -> Q.when('1234')
  load: ->


class SmtpClient
  connect: ->
  close: ->
  send: ->

Mailr = sandbox.require '../lib/mailr',
  requires:
    './config/config': config
    './clients/smtp_client': SmtpClient


describe "Mailr", ->
  beforeEach ->
    @connect = SmtpClient.prototype.connect = @stub()
    @send = SmtpClient.prototype.send = @stub().returns(Q.when('123'))
    @options =
      filename: 'test/fixtures/message1.email'
      account: 'myAccount'

  describe "#send", ->
    it "returns a promise", ->
      mailr = new Mailr()
      mailr.send(@options).then.should.be.a.function

    it "sends an email", (done) ->
      mailr = new Mailr()
      mailr.send(@options).then =>
        expect(@connect).to.have.been.calledWith('smtp-settings')
        expect(@send).to.have.been.called
        from = @send.getCall(0).args[0].from
        expect(from).to.equal 'Me <me@me.com>'
        done()





