require '../spec_helper'
Account = require '../../lib/config/account'
fs = require 'fs'
_ = require 'lodash'
Q = require 'q'

tmpDir = '.mailr-config-test'

describe "config/config", ->
  beforeEach ->
    @store =
      get: @stub()
    @config = sandbox.require '../../lib/config/config',
      requires:
        './password_store': @store

  describe "#load", ->
    describe "when the config dir doesn't exist", ->
      beforeEach ->
        fs.rmdirSync(tmpDir) if fs.existsSync(tmpDir)
      afterEach ->
        fs.rmdirSync(tmpDir) if fs.existsSync(tmpDir)

      it "creates it", ->
        @config.load(tmpDir)
        exists = fs.existsSync(tmpDir)
        expect(exists).to.be.true
        if exists
          isDir = fs.statSync(tmpDir).isDirectory()
          expect(isDir).to.be.true

      it "loads the accounts from 'config.coffee'", ->
        @config.load('test/fixtures/config-dir')
        accountNames = _.keys(@config.accounts)
        expect(accountNames).to.eql ['gmail']
        account = @config.accounts['gmail']
        expect(account.constructor.name).to.equal 'Account'
        expect(account.attribs).to.eql {
          name: 'gmail',
          service: 'Gmail',
          username: 'me@gmail.com'
        }

  describe "#findAccountByEmail", ->
    it "returns the account name where the username matches the address", ->
      @config.accounts =
        gmail_me:
          getEmail: -> 'me@gmail.com'
        gmail_you:
          getEmail: -> 'you@gmail.com'
      account = @config.findAccountByEmail('me@gmail.com')
      account.should.eql @config.accounts.gmail_me

  describe "#getFromAddresses", ->
    it "returns the fullname and email of all accounts", ->
      @config.accounts =
        example1:
          getFromAddress: -> '123'
        example2:
          getFromAddress: -> '456'
      expect(@config.getFromAddresses()).to.eql ['123', '456']

