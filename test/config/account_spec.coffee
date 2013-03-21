require '../spec_helper'
passwordStore =
  get: ->
Account = sandbox.require '../../lib/config/account',
  requires:
    './password_store': passwordStore


test = (methodName, attributes, output) ->
  describe "when #{JSON.stringify(attributes)}", ->
    it "returns #{JSON.stringify(output)}", ->
      account = new Account(attributes)
      expect(account[methodName]()).to.eql output

testWithArgs = (methodName, args, attributes, output) ->
  argsJSON = JSON.stringify(args)
  describe "(#{argsJSON}) when #{JSON.stringify(attributes)}", ->
    it "returns #{JSON.stringify(output)}", ->
      account = new Account(attributes)
      expect(account[methodName].apply(account, args)).to.eql output

describe "Account", ->

  describe "#getFromAddress", ->
    test 'getFromAddress', { username: 'bob@gmail.com' }, 'bob@gmail.com'
    test 'getFromAddress', { email: 'bob@gmail.com' }, 'bob@gmail.com'
    test 'getFromAddress', { email: 'email', username: 'user' }, 'email'
    test 'getFromAddress', { email: 'bob@gmail.com', fullname: 'Bob' }, 'Bob <bob@gmail.com>'

  describe "#getEmail", ->
    test 'getEmail', { username: 'bob@gmail.com' }, 'bob@gmail.com'
    test 'getEmail', { email: 'bob@gmail.com' }, 'bob@gmail.com'
    test 'getEmail', { email: 'bob@gmail.com', username: '123' }, 'bob@gmail.com'

  describe "#getUsername(protocol)", ->
    test 'getUsername', { username: 'bob' }, 'bob'
    testWithArgs 'getUsername', ['smtp'], { username: 'bob' }, 'bob'
    testWithArgs 'getUsername', ['smtp'], { smtp: { username: 'bob' } }, 'bob'

  describe "#getService", ->
    test 'getService', { service: '123' }, '123'

  describe "#getServer(protocol)", ->
    testWithArgs 'getServer', ['imap'], { imap: { host: 'my-server', port: 123 } },
      { host: 'my-server', port: 123 }
    testWithArgs 'getServer', ['imap'], { service: 'Gmail' },
      { host: 'imap.gmail.com', port: 993 }

  describe "#getPasswordKey(protocol)", ->
    testWithArgs 'getPasswordKey', ['smtp'], { name: 'myAccount', username: 'bob' },
      'myAccount'
    testWithArgs 'getPasswordKey', ['smtp'], { name: 'myAccount', smtp: { username: 'bob' } },
      'myAccount:smtp'

  describe "#getPassword(protocol)", ->
    beforeEach ->
      @account = new Account()
      @stub(@account, 'getPasswordKey').withArgs('smtp').returns('bob:smtp')
      @stub(passwordStore, 'get')

    it "gets the password from the password store", ->
      @account.getPassword('smtp')
      passwordStore.get.should.have.been.calledWith('bob:smtp')

    it "returns a promise", ->
      @account.getPassword('smtp').then.should.be.a.function

  describe "#getSmtpSettings", ->
    beforeEach ->
      @account = new Account(
        service: 'Gmail',
        username: 'me@gmail.com')
      @stub(@account, 'getPassword') \
        .withArgs('smtp').returns(Q.when('the-password'))

    it "returns a promise", ->
      @account.getSmtpSettings().then.should.be.a.function

    it "resolves with node-mailer settings", (done) ->
      @account.getSmtpSettings().should.become(
        service: 'Gmail'
        auth:
          user: 'me@gmail.com'
          pass: 'the-password'
      ).and.notify(done)
