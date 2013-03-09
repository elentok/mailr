require '../spec_helper'
Config = require '../../lib/config/config'
Account = require '../../lib/config/account'
fs = require 'fs'
_ = require 'lodash'

tmpDir = '.mailr-config-test'

describe "Config", ->
  describe "#load", ->
    describe "when the config dir doesn't exist", ->
      beforeEach ->
        fs.rmdirSync(tmpDir) if fs.existsSync(tmpDir)
      afterEach ->
        fs.rmdirSync(tmpDir) if fs.existsSync(tmpDir)

      it "creates it", ->
        config = new Config(path: tmpDir)
        config.load()
        exists = fs.existsSync(tmpDir)
        expect(exists).to.be.true
        if exists
          isDir = fs.statSync(tmpDir).isDirectory()
          expect(isDir).to.be.true

      it "loads the accounts from 'config.coffee'", ->
        config = new Config(path: 'test/fixtures/config-dir')
        config.load()
        accountNames = _.keys(config.accounts)
        expect(accountNames).to.eql ['gmail']
        account = config.accounts['gmail']
        expect(account).to.be.instanceof(Account)
        expect(account.attribs).to.eql {
          service: 'Gmail',
          username: 'me@gmail.com'
        }

  describe "#getPassword('myAccount', protocol)", ->
    beforeEach ->
      @passwordStore =
        getPassword: sinon.stub().returns('the-password')
      @config = new Config(passwordStore: @passwordStore)

    describe "when accounts = { myAccount: getPasswordKeySuffix -> ':bla' }", ->
      it "gets the password from 'myAccount:bla'", ->
        @config.accounts =
          myAccount:
            getPasswordKeySuffix: -> ':bla'
        password = @config.getPassword('myAccount', 'smtp')
        expect(@passwordStore.getPassword).to.have.been.calledWith('myAccount:bla')
        expect(password).to.equal 'the-password'

  describe "#findAccountByEmail", ->
    it "returns the account name where the username matches the address", ->
      config = new Config()
      config.accounts =
        gmail_me:
          getEmail: -> 'me@gmail.com'
        gmail_you:
          getEmail: -> 'you@gmail.com'
      accountName = config.findAccountByEmail('me@gmail.com')
      expect(accountName).to.equal 'gmail_me'

  describe "#getFromAddresses", ->
    it "returns the fullname and email of all accounts", ->
      config = new Config()
      config.accounts =
        example1:
          getFromAddress: -> '123'
        example2:
          getFromAddress: -> '456'
      expect(config.getFromAddresses()).to.eql ['123', '456']

