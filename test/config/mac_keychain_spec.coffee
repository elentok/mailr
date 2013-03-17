require '../spec_helper'

keychainSync = {}

keychain = sandbox.require '../../lib/config/mac_keychain',
  requires:
    'keychain-sync': keychainSync

describe "config/mac_keychain", ->
  beforeEach ->
    keychainSync.getPassword = @stub()
    keychainSync.setPassword = @stub()

  describe "#get", ->
    it "forwards the call to keychainSync.getPassword", ->
      keychain.get('account', 'key')
      keychainSync.getPassword.should.have.been.calledWith('account', 'key')

    it "returns the output from getPassword", ->
      keychainSync.getPassword.withArgs('account', 'key').returns('pass')
      keychain.get('account', 'key').should.equal 'pass'

  describe "#set", ->
    it "forwards the call to keychainSync.setPassword", ->
      keychain.set('account', 'key', 'pass')
      keychainSync.setPassword.should.have.been.calledWith('account', 'key', 'pass')
