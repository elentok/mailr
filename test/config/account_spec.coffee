require '../spec_helper'

fs =
  mkdirSync: ->
  existsSync: -> true
  writeFileSync: ->
passwordStore =
  get: ->
config = {}
Account = sandbox.require '../../lib/config/account',
  requires:
    './config': config
    './password_store': passwordStore
    fs: fs


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

    it "resolves with node-mailer settings", ->
      @account.getSmtpSettings().should.become(
        service: 'Gmail'
        auth:
          user: 'me@gmail.com'
          pass: 'the-password'
      )

  describe "#getContactsSettings", ->
    beforeEach ->
      @account = new Account(
        service: 'Gmail',
        username: 'me@gmail.com')
      @stub(@account, 'getPassword') \
        .withArgs('contacts').returns(Q.when('the-password'))
    it "returns a promise", ->
      @account.getContactsSettings().then.should.be.a.function
    it "resolves with contacts settings", ->
      @account.getContactsSettings().should.become(
        email: 'me@gmail.com'
        password: 'the-password'
      )

  describe "#getImapSettings", ->
    beforeEach ->
      @account = new Account(
        service: 'Gmail',
        username: 'me@gmail.com')
      @stub(@account, 'getPassword') \
        .withArgs('imap').returns(Q.when('the-password'))
    it "returns a promise", ->
      @account.getImapSettings().then.should.be.a.function
    it "resolves with imap settings", ->
      @account.getImapSettings().then (settings) ->
        expect(settings[0]).to.equal 993
        expect(settings[1]).to.equal 'imap.gmail.com'
        expect(settings[2]).to.eql {
          secureConnection: true
          auth:
            user: 'me@gmail.com'
            pass: 'the-password'
        }

  describe "#getDataPath", ->
    beforeEach ->
      config.currentPath = 'the-path'
      @account = new Account(name: 'myAccount')
    it "creates the /accounts if it doesn't exist", ->
      @stub(fs, 'mkdirSync')
      @stub(fs, 'existsSync') \
        .withArgs('the-path/accounts').returns(false) \
        .withArgs('the-path/accounts/myAccount').returns(false)
      @account.getDataPath()
      fs.mkdirSync.should.have.been.calledWith('the-path/accounts')
      fs.mkdirSync.should.have.been.calledWith('the-path/accounts/myAccount')
    it "creates the /accounts/{myAccount} path if it doesn't exist", ->
      @stub(fs, 'mkdirSync')
      @stub(fs, 'existsSync') \
        .withArgs('the-path/accounts').returns(true) \
        .withArgs('the-path/accounts/myAccount').returns(false)
      @account.getDataPath()
      fs.mkdirSync.should.not.have.been.calledWith('the-path/accounts')
      fs.mkdirSync.should.have.been.calledWith('the-path/accounts/myAccount')
    it "returns {config.currentPath}/accounts/{accountName}", ->
      @account.getDataPath().should.equal 'the-path/accounts/myAccount'



