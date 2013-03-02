require '../spec_helper'

nodemailer = {}

SmtpClient = sandbox.require '../../lib/clients/smtp_client',
  requires:
    nodemailer: nodemailer

describe 'SmtpClient', ->
  beforeEach ->
    @transport = {}
    nodemailer.createTransport = sinon.stub().returns(@transport)

  describe "#getConnectArgs(accountName)", ->
    it "calls callback with nodemailer-oriented settings", ->
      config =
        accounts:
          myAccount:
            service: 'Gmail'
            username: 'me@gmail.com'
        getPassword: sinon.stub().callsArgWith(2, null, 'the-password')

      callback = sinon.spy()

      client = new SmtpClient(config)
      client.getConnectArgs 'myAccount', callback
      settings =
        service: 'Gmail'
        auth:
          user: 'me@gmail.com'
          pass: 'the-password'
      expect(callback).to.have.been.calledOnce
      expect(callback.getCall(0).args[0]).to.eql null
      expect(callback.getCall(0).args[1]).to.eql settings

  describe "#connect(accountName)", ->
    beforeEach ->
      @settings = 'the-settings'
      @client = new SmtpClient(null)
      sinon.stub(@client, 'getConnectArgs').callsArgWith(1, null, @settings)

    it "connects to the account's smtp server", ->
      @client.connect('myAccount', sinon.spy())
      expect(nodemailer.createTransport).to.have.been.calledWith('SMTP', @settings)

    it "calls the callback on when done", ->
      callback = sinon.spy()
      @client.connect('myAccount', callback)
      expect(callback).to.have.been.called

  describe "#send", ->
    beforeEach ->
      @message =
        from: 'me'
        to: 'you'
        subject: 'hi'
        text: 'yo!'
      @transport.sendMail = sinon.stub()

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
