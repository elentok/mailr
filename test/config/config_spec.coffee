require '../spec_helper'
Config = require '../../lib/config/config'
fs = require 'fs'

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
        expect(config.accounts).to.eql {
          gmail:
            service: 'Gmail'
            username: 'me@gmail.com'
        }

  describe "#getPassword('myAccount', 'smtp')", ->
    beforeEach ->
      @passwordStore =
        getPassword: sinon.stub().returns('the-password')
      @config = new Config(passwordStore: @passwordStore)

    describe "when accounts = { myAccount: { username: '123' } }", ->
      it "gets the password from 'myAccount'", ->
        @config.accounts =
          myAccount:
            username: '123'
        password = @config.getPassword('myAccount', 'smtp')
        expect(@passwordStore.getPassword).to.have.been.calledWith('myAccount')
        expect(password).to.equal 'the-password'


    describe "when accounts = { myAccount: { smtp: { username: '123' } }", ->
      it "gets the password from 'myAccount:smtp'", ->
        @config.accounts =
          myAccount:
            smtp:
              username: '123'
        password = @config.getPassword('myAccount', 'smtp')
        expect(@passwordStore.getPassword).to.have.been.calledWith('myAccount:smtp')
        expect(password).to.equal 'the-password'

  describe "#findAccountByEmail", ->
    it "returns the account name where the username matches the address", ->
      config = new Config()
      config.accounts =
        gmail_me:
          username: 'me@gmail.com'
        gmail_you:
          username: 'you@gmail.com'
      accountName = config.findAccountByEmail('me@gmail.com')
      expect(accountName).to.equal 'gmail_me'

