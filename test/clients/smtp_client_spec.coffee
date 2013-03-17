require '../spec_helper'

nodemailer = {}

SmtpClient = sandbox.require '../../lib/clients/smtp_client',
  requires:
    nodemailer: nodemailer

describe 'SmtpClient', ->
  beforeEach ->
    @transport = {}
    nodemailer.createTransport = @stub().returns(@transport)

  describe "#getConnectArgs(account)", ->
    beforeEach ->
      @client = new SmtpClient()
      @account =
        getService: -> 'Gmail'
        getUsername: -> 'me@gmail.com'
        getPassword: -> Q.when('the-password')

    it "returns a promise", ->
      @client.getConnectArgs(@account).then.should.be.a.function

    it "resolves the callback with nodemailer-oriented settings", (done) ->
      @client.getConnectArgs(@account).should.become(
        service: 'Gmail'
        auth:
          user: 'me@gmail.com'
          pass: 'the-password'
      ).and.notify(done)

  describe "#connect(account)", ->
    beforeEach ->
      @args = 'the-connect-args'
      @client = new SmtpClient()
      @stub(@client, 'getConnectArgs').returns(Q.when(@args))

    it "returns a promise", ->
      @client.connect('the-account').then.should.be.a.function

    it "connects to the account's smtp server", (done) ->
      @client.connect('the-account').then =>
        expect(nodemailer.createTransport).to.have.been.calledWith('SMTP', @args)
        done()

  describe "#send", ->
    beforeEach ->
      @message =
        from: 'me'
        to: 'you'
        subject: 'hi'
        text: 'yo!'
      @transport.sendMail = @stub()

    it "sends an email message", ->
      client = new SmtpClient()
      client.transport = @transport
      client.send(@message, null)
      expect(@transport.sendMail).to.have.been.calledOnce
      options = @transport.sendMail.getCall(0).args[0]
      expect(options).to.eql
        from: 'me'
        to: 'you'
        subject: 'hi'
        text: 'yo!'
