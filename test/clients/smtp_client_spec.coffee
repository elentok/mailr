require '../spec_helper'

nodemailer = {}

SmtpClient = sandbox.require '../../lib/clients/smtp_client',
  requires:
    nodemailer: nodemailer

describe 'SmtpClient', ->
  beforeEach ->
    @transport = {}
    nodemailer.createTransport = @stub().returns(@transport)

  describe "#connect(settings)", ->
    beforeEach ->
      @args = 'the-connect-args'
      @client = new SmtpClient()

    it "connects to the account's smtp server", ->
      @client.connect(@args)
      expect(nodemailer.createTransport).to.have.been.calledWith('SMTP', @args)

  describe "#send", ->
    beforeEach ->
      @message =
        from: 'me'
        to: 'you'
        subject: 'hi'
        text: 'yo!'
      @transport.sendMail = @stub()
      @client = new SmtpClient()
      @client.transport = @transport

    it "returns a promise", ->
      @client.send(@message).then.should.be.a.function

    it "sends an email message", (done) ->
      @transport.sendMail.callsArgWith(1, null, 'bla')
      @client.send(@message).then =>
        expect(@transport.sendMail).to.have.been.calledOnce
        options = @transport.sendMail.getCall(0).args[0]
        expect(options).to.eql @message
        done()
